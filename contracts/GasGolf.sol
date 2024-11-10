// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract GasGolf {
    uint public num;
    // 1 start -- 51461
    // 2 use calldata -- 49508
    // 3 locate state var to memory,不需要每次循环都访问读取状态变量,只在循环前以及循环完成访问状态变量 -- 48861
    // 4 short circuit -- 48524
    // 5 cache array length -- 48480
    // 6 load array member to memory -- 48180
    function sumIfEvenAndLessThan99(uint[] calldata arr) external {
        uint n = num;
        uint len = arr.length;
        for (uint i = 0; i<len; i++) {
            uint item = arr[i];
            if(item % 2 != 0 && item < 99) {
                n += item;
            }
        }

        num = n;
    }
}