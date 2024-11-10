// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Kill {

    constructor() payable {}

    function kill() external {
        // 销毁该合约,将该合约的余额强制转到合约调用者
        selfdestruct(payable(msg.sender));
    }

    function testCall() external pure returns(uint) {
        return 123;
    }

}

contract KillHelper {

    function getBalance() external view returns (uint){
        return address(this).balance;
    }

    function killOther(Kill _kill) external {
        _kill.kill();
    }
}

event HelperLog(uint256 balance);

contract NewKillHelper {
    Kill public kill;

    function test() external payable {
        // 333
        emit HelperLog(address(this).balance);
        Kill _kill = new Kill{value:222}();
        kill = _kill;
        // 111
        emit HelperLog(address(this).balance);
        _kill.kill();
        // 333
        emit HelperLog(address(this).balance);

    }
}