// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract AccessControl {
    mapping(bytes32 => mapping(address=>bool)) public roles;
    // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private ADMIN = keccak256(abi.encodePacked("ADMIN"));
    // 0x2db9fd3d099848027c2383d0a083396f6c41510d7acfd92adc99b6cffcf31e96
    bytes32 private USER = keccak256(abi.encodePacked("USER"));

    // 修改状态变量时(发生链上数据修改),需要通过事件通知链下
    // 升级权限事件
    event GrantRole(bytes32 role,address account);
    // 撤销权限事件
    event RevokeRole(bytes32 role,address account);

    modifier onlyRole(bytes32 _role) {
        require(roles[_role][msg.sender],"have no auth");
        _;
    }

    constructor() {
        roles[ADMIN][msg.sender] = true;
    }

   
    function _grantRole(bytes32 _role,address _account) internal {
        roles[_role][_account] = true;
        emit GrantRole(_role, _account);
    }

    function grantRole(bytes32 _role,address _account) external onlyRole(ADMIN) {
        _grantRole(_role,_account);
    }



    function _revokeRole(bytes32 _role,address _account) internal {
        roles[_role][_account] = false;
        emit RevokeRole(_role, _account);
    }

    function revokeRole(bytes32 _role,address _account) external onlyRole(ADMIN) {
        _revokeRole(_role,_account);
    }
} 