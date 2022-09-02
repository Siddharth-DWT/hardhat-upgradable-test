// contracts/GameItems.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";



contract SignatureChecker is Ownable {
    using ECDSA for bytes32;
    bool public checkSignatureFlag = true;
    address private validatorAddress = 0x404F0fA265E92198B7E3D332163AeECeE0CFfA95;

    function setValidatorAddress(address _validatorAddress) external{
        validatorAddress = _validatorAddress;
    }

    function setCheckSignatureFlag(bool newFlag) public onlyOwner {
        checkSignatureFlag = newFlag;
    }

    function getSigner(bytes32 signedHash, bytes memory signature) public pure returns (address)
    {
        return signedHash.toEthSignedMessageHash().recover(signature);
    }

    function checkSignature(bytes32 signedHash, bytes memory signature) public view returns (bool) {
        return getSigner(signedHash, signature) == validatorAddress;
    }

}