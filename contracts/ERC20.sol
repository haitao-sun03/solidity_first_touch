// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IERC20 {
    function balanceOf(address account) external returns(uint);

    function allowance(address owner,address spender) external returns(uint);

    function totalSupply() external returns (uint);

    function transfer(address receiver,uint amount) external returns(bool);

    function approve(address recipient,uint amount) external returns(bool);

    function transferFrom(address sender,address recipient,uint amount) external returns (bool);

    event Transfer(address indexed sender,address indexed receiver,uint amount);

    event Approve(address indexed owner,address indexed spender,uint amount); 
} 

contract ERC20 is IERC20 {
    mapping(address=>uint) public balanceOf;
    mapping(address=>mapping(address=>uint)) public allowance;

    uint public totalSupply;
    string public symbol;
    uint8 public decimals;

    constructor() {
        totalSupply = 1000;
        symbol = "haitao";
        decimals = 3;
    }



    function transfer(address receiver,uint amount) external returns(bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[receiver] += amount;
        emit Transfer(msg.sender, receiver, amount);
        return true;
    }

    // 通过CrowdFund合约使用ERC20合约,加深了理解:
    // 相当于调用的外币账户地址授权了CrowdFund合约账户:此token transferFrom的额度
    function approve(address recipient,uint amount) external returns(bool) {
        allowance[msg.sender][recipient] = amount;
        emit Approve(msg.sender, recipient, amount);
        return true;
    }

    // 在CrowdFund的例子中,调用transferFrom是为了众筹pledge,此时sender是一个外部账户,recipient就是CrowdFund合约账户
    // 因此在pledge之前,需要用所有可能参与众筹的外部账户approve一下CrowdFund合约账户
    // 代表到时候合约账户的逻辑中,可以调用transferFrom,从sender转账给recipient
    function transferFrom(address sender,address recipient,uint amount) external returns (bool) {
        allowance[sender][recipient] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        return true;
    }

    function mint(uint amount) external {
        balanceOf[msg.sender] += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burn(uint amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender,address(0) , amount);
    }


}