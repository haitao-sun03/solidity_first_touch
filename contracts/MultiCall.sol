// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract MultiCallHelper {

    function fun1() external view returns(uint,uint) {
        return (1,block.timestamp);
    }

    function fun2() external view returns(uint,uint) {
        return (2,block.timestamp);
    }

    function getData1() external pure returns (bytes memory ) {
        return abi.encodeWithSelector(this.fun1.selector);
    }

    function getData2() external pure returns (bytes memory ) {
        return abi.encodeWithSelector(this.fun2.selector);
    }
}

contract MultiCall {

    function multiCall(address[] memory targets,bytes[] calldata datas) external view returns(bytes[] memory ) {
        require(targets.length == datas.length,"targets.length != datas.length");

        bytes[] memory results = new bytes[](targets.length);
        for (uint i = 0; i < targets.length; i++) {
            (bool success,bytes memory res) = targets[i].staticcall(datas[i]);
            require(success,"static call fail");
            results[i] = res;
        }

        return results;
    }
}