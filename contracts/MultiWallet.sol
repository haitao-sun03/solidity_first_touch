// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract MultiSigWallet {
    event Deposite(address indexed sender,uint amount);
    event Subimit(uint indexed  txId);
    event Approved(address indexed owner,uint indexed txId);
    event Revoke(address indexed owner,uint indexed txId);
    event Execute(uint indexed txId);


    address[] public owners;
    mapping(address=>bool) public isOwner;
    uint public requiredNum;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool isExecuted;        
    }

    Transaction[] public transactions;
    mapping(uint=>mapping (address=>bool)) approves;



    constructor(address[] memory _owners,uint _requiredNum) {
        require(_owners.length > 0,"_owners invalid");
        require(_requiredNum > 0 && _requiredNum <= _owners.length,"_requiredNum invalid");

        for (uint i = 0;i < _owners.length;i++) {
            address owner = _owners[i];
            require(owner !=address(0),"have invalid owner");
            require(!isOwner[owner],"owner exists");

            owners.push(owner);
            isOwner[owner] = true;
        }

        requiredNum = _requiredNum;
    }

    receive() external payable {
        emit Deposite(msg.sender, msg.value);
    }

    modifier onlyOwner {
        require(isOwner[msg.sender],"not owner,can't call");
        _;
    }

    function submit(address _to,uint _value,bytes memory _data) external onlyOwner {
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            isExecuted:false
        }));

        emit Subimit(transactions.length - 1);
    }

    modifier txExist(uint _txId) {
        require(_txId < transactions.length ,"tx not exists");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!approves[_txId][msg.sender],"tx already approved");
        _;
    }

    modifier beenApproved(uint _txId) {
        require(approves[_txId][msg.sender],"tx is not approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId].isExecuted,"tx isExcecuted!");
        _;
    }

    function approve(uint _txId) external onlyOwner txExist(_txId) notApproved(_txId) notExecuted(_txId)  {
        approves[_txId][msg.sender] = true;
        emit Approved(msg.sender, _txId);
    }

    function revoke(uint _txId) external onlyOwner txExist(_txId) beenApproved(_txId) notExecuted(_txId)  {
        approves[_txId][msg.sender] = false;
        emit Revoke(msg.sender, _txId);
    }

    function getApprovals(uint _txId) private view returns(uint) {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if(approves[_txId][owners[i]]) {
                count ++;
            }
        }
        return count;
    }

    function execute(uint _txId) external onlyOwner txExist(_txId) notExecuted(_txId) {
        require(getApprovals(_txId) >= requiredNum,"approves < requiredNum");
        
        Transaction storage transaction = transactions[_txId];
        transaction.isExecuted = true;
        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);        

        require(success,"tx call fail");

        emit Execute(_txId);
    }

}