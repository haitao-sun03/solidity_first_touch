// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IERC20} from "./ERC20.sol";

contract ERC20Faucet {

    event SendToken(address Receiver,uint256 amount);

    address public ERC20Addr;

    mapping(address=>bool) public requestedAddress;

    uint256 public amountLimitPer = 100;

    constructor(address _ERC20Addr) {
        ERC20Addr = _ERC20Addr;
    }

    function requestTokens() external {
        require(!requestedAddress[msg.sender],"multiple get from faucet");
        IERC20 erc20 = IERC20(ERC20Addr);
        require(erc20.balanceOf(address(this))>amountLimitPer,"faucet amount not enough");
        erc20.transfer(msg.sender, amountLimitPer);
        requestedAddress[msg.sender] = true;
        emit SendToken(msg.sender,amountLimitPer);
    }








    

}