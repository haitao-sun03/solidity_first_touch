// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract VerifySig {

    
    /**
    *signer:账户公钥
    *message:待加密原文
    *sig:电子签名
    */
    function verify(address signer,string memory message,bytes memory sig) external pure returns(bool) {
        bytes32 messageHash = hash(message);
        bytes32 ethHashV = ethHash(messageHash);
        return recover(ethHashV,sig) == signer;
    }

    function hash(string memory message) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(message));
    }

    function ethHash(bytes32 hashValue) public pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",hashValue));
    }

    function recover(bytes32 ethHash1,bytes memory sig) public pure returns(address) {
        (bytes32 r,bytes32 s,uint8 v) = _split(sig);
        return ecrecover(ethHash1, v, r, s);
    }

    function _split(bytes memory sig) internal pure returns(bytes32 r,bytes32 s,uint8 v) {
        require(sig.length == 65,"sig len invalid");

        assembly {
            r := mload(add(sig,32))
            s := mload(add(sig,64))
            v := byte(0,mload(add(sig,96)))
        }
    }

}