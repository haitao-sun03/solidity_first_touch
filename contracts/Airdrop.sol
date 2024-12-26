// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import {IERC20} from "./ERC20.sol";

contract Airdrop {
    address public tokenAddr;

    constructor(address _tokenAddr) {
        tokenAddr=_tokenAddr;
    }

    function getSum(uint256[] calldata arr) public pure returns(uint sum) {
        for (uint8 i; i < arr.length; i++) {
            sum += arr[i];
        }
    }

    function multiTransferToken(address[] calldata _addrs,uint256[] calldata _amounts) external {
        require(_addrs.length == _amounts.length,"length not equal");
        IERC20 token = IERC20(tokenAddr);
        require(token.allowance(msg.sender, address(this)) >= getSum(_amounts),"Need enough approve amount");

        for (uint8 i; i < _addrs.length; i++) {
            token.transferFrom(msg.sender, _addrs[i], _amounts[i]);
        }
    }

    mapping(address=>uint256) public failTransferList;

    function multiTransferEth(address[] calldata _addrs,uint256[] calldata _amounts) external payable {
        require(_addrs.length == _amounts.length,"length not equal");
        uint amount = getSum(_amounts);
        require(msg.value == amount,"msg.value error");

        for (uint8 i; i < _addrs.length; i++) {
            (bool success, ) = _addrs[i].call{value:_amounts[i]}("");
            if (!success) {
                failTransferList[_addrs[i]] = _amounts[i];
            }
        }
    }
}