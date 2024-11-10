// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}


contract CrowdFund {
    event Lauch(uint indexed id,address indexed creator,uint goal,uint32 startAt,uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint indexed id,address indexed pledger,uint amount);
    event UnPledge(uint indexed id,address indexed pledger,uint amount);
    event Claim(uint id);
    event Refund(uint indexed id,address indexed refunder,uint amount);

    uint public idGenerator;

    struct Compaign {
        address creator;
        uint32 startAt;
        uint32 endAt;
        // 众筹目标
        uint goal;
        // 众筹金额
        uint pledged;
        bool claimed;
    }

    IERC20 immutable public token;
    // 活动id=>活动
    mapping(uint=>Compaign) public compaigns;
    // 活动id=>众筹者=>众筹金额
    mapping(uint=>mapping(address=>uint)) public pledgedAmount;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function lauch(uint32 _startAt,uint32 _endAt,uint _goal) external {
        require(_startAt>block.timestamp,"startAt < now");
        require(_endAt > _startAt,"endAt < startAt");
        require(_endAt < block.timestamp + 90 days,"endAt > DURATION");

        uint id = idGenerator + 1;
        compaigns[id] = Compaign({
            creator: msg.sender,
            startAt: _startAt,
            endAt: _endAt,
            goal: _goal,
            pledged:0,
            claimed: false
        });

        emit Lauch(id,msg.sender,_goal,_startAt,_endAt);
    }

    function cancel(uint _id) external {
        Compaign memory compaign =  compaigns[_id];
        require(msg.sender == compaign.creator,"not creator");
        require(compaign.startAt < block.timestamp,"started");

        delete compaigns[_id];

        emit Cancel(_id);

    }

    function pledge(uint _id,uint _amount) external {
        Compaign storage compaign =  compaigns[_id];
        require(block.timestamp > compaign.startAt,"not start");
        require(block.timestamp < compaign.endAt,"ended");

        compaign.pledged += _amount;
        pledgedAmount[_id][msg.sender] += _amount;
        // 发送token
        token.transferFrom(msg.sender,address(this),_amount);

        emit Pledge(_id,msg.sender,_amount);

    }

    function unpledge(uint _id,uint _amount) external {
        Compaign storage compaign =  compaigns[_id];
        require(block.timestamp < compaign.endAt ,"ended");
        require(pledgedAmount[_id][msg.sender] >= _amount,"over exceed");
        compaign.pledged -= _amount;
        pledgedAmount[_id][msg.sender] -= _amount;
        token.transfer(msg.sender,_amount);

        emit UnPledge(_id,msg.sender,_amount);

    }

    function claim(uint _id) external {
        Compaign storage compaign =  compaigns[_id];
        require(block.timestamp > compaign.endAt,"not end");
        require(msg.sender == compaign.creator,"not creator");
        require(compaign.pledged >= compaign.goal,"goal fail");
        require(!compaign.claimed,"claimed");

        compaign.claimed = true;
        token.transfer(compaign.creator , compaign.pledged);

        emit Claim(_id);
    }

    // 只有在goal没有达成时才能退款
    function refund(uint _id) external {
        Compaign memory compaign =  compaigns[_id];
        require(block.timestamp >= compaign.endAt,"not end");
        require(compaign.pledged < compaign.goal,"goal success");

        uint refundVal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;

        token.transfer(msg.sender,refundVal);

        emit Refund(_id,msg.sender,refundVal);
    }


    
}