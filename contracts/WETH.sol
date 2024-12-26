// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {ERC20} from "./ERC20.sol";

/**
* 同比例将ETH兑换为WETH,旨在方便对WETH进行跨链等操作
*/
contract WETH is ERC20 {
    
    constructor(uint256 _totalSupply,string memory _symbol,uint8 _decimals) ERC20(_totalSupply,_symbol,_decimals) {

    }

    event Deposite(address sender,uint256 amount);
    event Withdrawal(address withdrawer,uint256 amount);

    fallback() external payable { 
        deposite();
    }

    receive() external payable {
        deposite();
    }

    // 存入ETH，同比例兑换WETH
    function deposite() public payable {
        _mint(msg.sender,msg.value);
        emit Deposite(msg.sender,msg.value);
    }

    // 销毁WETH，返回ETH
    function withdrawal(uint amount) public {
        require(balanceOf[msg.sender] >= amount,"Insufficient token");
        _burn(msg.sender,amount);
        (bool success,) = payable(msg.sender).call{value:amount}("");
        require(success,"transfer fail");
        emit Withdrawal(msg.sender,amount);
    }
}