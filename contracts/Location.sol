// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract DataLocations {

    mapping(uint => address) public map;
    struct MyStruct {
        uint foo;
    }
    mapping(uint => MyStruct) public myStructs;

    constructor() {
        myStructs[111] = MyStruct({foo:1});
        myStructs[222] = MyStruct({foo:2});
    }

    function fun() public {
        MyStruct storage m1 = myStructs[111];
        m1.foo = 333;
        MyStruct memory m2 = myStructs[222];
        m2.foo = 444;
    }

    function callDataFun(uint[] calldata arr) public returns(uint[] memory) {
        _internal(arr);
        return arr;
    }

    function _internal(uint[] memory arr) internal {
        uint num = arr[0] + 1;
        arr[1] = 666;

    }

}
