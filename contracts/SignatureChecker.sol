// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureChecker is Ownable {
    using ECDSA for bytes32;
    address public validatorAddress;
    bool public checkSignatureFlag;

    constructor(){
        validatorAddress = 0x404F0fA265E92198B7E3D332163AeECeE0CFfA95;
        checkSignatureFlag = true;
    }

    function setCheckSignatureFlag(bool newFlag) external onlyOwner {
        checkSignatureFlag = newFlag;
    }

    function setValidatorAddress(address _validatorAddress) external onlyOwner{
        validatorAddress = _validatorAddress;
    }

    function getSigner(bytes32 signedHash, bytes memory signature) public pure returns (address){
        return signedHash.toEthSignedMessageHash().recover(signature);
    }

    function checkSignature(bytes32 signedHash, bytes memory signature) public view returns (bool) {
        return getSigner(signedHash, signature) == validatorAddress;
    }

}