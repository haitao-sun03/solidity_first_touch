// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;



contract Test {

    uint public z;
    function add(uint x,uint y) external pure returns(uint sum) {
        sum = x+y;
    }

    function setZ(uint _z) external {
        z=_z;
    }
    
}

contract CallTest {
    function pay(address addr) external payable {
        payable(addr) .transfer(123);
    }

    struct Person {
        string name;
        uint age;
    }

    mapping(uint=>Person) public persons;

    function getPerson(uint _id) external view returns(Person memory ){
        return persons[_id];
    }

}

