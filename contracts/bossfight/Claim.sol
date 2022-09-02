// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./SignatureChecker.sol";


contract Claim is  SignatureChecker {
    function executeClaim(bytes memory sig) external returns(bool, bytes32){
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, sig);
        require(isSender, "Invalid Sender");
        return (isSender,message);
    }
}