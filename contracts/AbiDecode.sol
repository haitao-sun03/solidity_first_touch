// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract ABIDecode {
    struct MyStruct {
        string name;
        uint[] arr;
    }
    
    function encode(uint x,address addr,uint[] memory arr,MyStruct memory myStruct) external pure returns(bytes memory) {
        return abi.encode(x,addr,arr,myStruct);
    }

    function decode(bytes memory data) external pure returns(uint x,address addr,uint[] memory arr,MyStruct memory myStruct) {
        (x,addr,arr,myStruct) = abi.decode(data,(uint,address,uint[],MyStruct));
    }


}