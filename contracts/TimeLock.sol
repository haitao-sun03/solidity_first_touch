// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TimeLock {

    address owner;

    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner,"not owner");
        _;
    }

    event Queue(bytes32 indexed txId,address indexed target,uint value,string func,bytes data,uint timestamp);
    event Execute(bytes32 indexed txId,address indexed target,uint value,string func,bytes data,uint timestamp);
    event Cancel(bytes32 indexed txId);

    mapping(bytes32=>bool) public queued;
    uint constant public  MIN_DELAY = 10;
    uint constant public MAX_DELAY = 1000;


    function getTxId(address _target,uint _value,string calldata _func,bytes  calldata _data,uint _timestamp) private pure returns(bytes32) {
        return keccak256(abi.encode(_target,_value,_func,_data,_timestamp));
    }
    function queue(address _target,uint _value,string calldata _func,bytes  calldata _data,uint _timestamp) onlyOwner external {
        // generate txId
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        // check txId
        require(!queued[txId],"already queued");
        // timestamp
        require(_timestamp >= block.timestamp + MIN_DELAY && _timestamp <= block.timestamp + MAX_DELAY,"timestamp not valid");
        
        queued[txId] = true;

        emit Queue(txId, _target, _value,_func,_data, _timestamp);
    }

    function execute(address _target,uint _value,string calldata _func,bytes  calldata _data,uint _timestamp) onlyOwner external returns(bytes memory) {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        require(queued[txId],"not queue");
        require(_timestamp < block.timestamp );

        queued[txId] = false;
        bytes memory data;
        // 
        if(bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))),_data);
            data = abi.encodeWithSignature(_func, _data);
        }else {
            // 调用fallback函数
            data = _data;
        }

        (bool success,bytes memory res) = _target.call{value:_value}(data);
        require(success,"call failed");

        emit Execute(txId,_target,_value,_func,_data,_timestamp);

        return res;

    }

    function cancel(address _target,uint _value,string calldata _func,bytes  calldata _data,uint _timestamp) onlyOwner external {
        bytes32 txId = getTxId(_target, _value, _func, _data, _timestamp);
        require(queued[txId],"not queue");
        queued[txId] = false;

        emit Cancel(txId);
    }



}

contract Bussiness {
    address public timeLock;

    constructor(address _timeLock) {
        timeLock = _timeLock;
    }

    function test() external view {
        require(msg.sender == timeLock);
        // more code
    }

   
}

contract Temp {
    // 0x24ccab8f
     function testAbiPacked(string calldata _func,bytes calldata _data) external pure returns(bytes memory){
        return abi.encodePacked(bytes4(keccak256(bytes(_func))),_data);
    }

    //0x24ccab8f000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000
    function testAbiSig(string calldata _func,bytes calldata _data) external pure returns(bytes memory){
            return abi.encodeWithSignature(_func, _data);
    }

    function nolimitLoop() external pure  {
        uint i = 0;
        while(true) {
            i++;
        }
    }
}