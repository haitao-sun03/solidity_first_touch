// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ABIDecode {
    // struct MyStruct {
    //     string name;
    //     uint[] arr;
    // }
    
    function encode(uint x,address addr,uint[] memory arr) external pure returns(bytes memory) {
        return abi.encode(x,addr,arr);
    }

    function encodePacked(uint x,address addr,uint[] memory arr) public pure returns(bytes memory result) {
        result = abi.encodePacked(x,addr,arr);
    }

    function decode(bytes memory data) external pure returns(uint x,address addr,uint[] memory arr) {
        (x,addr,arr) = abi.decode(data,(uint,address,uint[]));
    }


}