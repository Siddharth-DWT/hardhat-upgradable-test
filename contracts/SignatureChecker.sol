// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureChecker is Ownable {
    using ECDSA for bytes32;
    address public validatorAddress;

    constructor(){
        validatorAddress = msg.sender;
    }

    function setValidatorAddress(address _validatorAddress) external onlyOwner{
        validatorAddress = _validatorAddress;
    }

    function getSigner(bytes32 signedHash, bytes memory signature) public pure returns (address){
        return signedHash.toEthSignedMessageHash().recover(signature);
    }

    function checkSignature(bytes32 signedHash, bytes memory signature) external view returns (bool) {
        return getSigner(signedHash, signature) == validatorAddress;
    }

}