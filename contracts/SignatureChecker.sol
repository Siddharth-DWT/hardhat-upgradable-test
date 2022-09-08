// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/cryptography/ECDSAUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SignatureChecker is OwnableUpgradeable {
    using ECDSAUpgradeable for bytes32;
    address private validatorAddress;
    bool public checkSignatureFlag;

    function __SigChecker_init() internal onlyInitializing {
        validatorAddress = 0x404F0fA265E92198B7E3D332163AeECeE0CFfA95;
        checkSignatureFlag = true;
    }

    function setCheckSignatureFlag(bool newFlag) external onlyOwner {
        checkSignatureFlag = newFlag;
    }

    function setValidatorAddress(address _validatorAddress) external onlyOwner{
        validatorAddress = _validatorAddress;
    }

    function getSigner(bytes32 signedHash, bytes memory signature) internal pure returns (address)
    {
        return signedHash.toEthSignedMessageHash().recover(signature);
    }

    function checkSignature(bytes32 signedHash, bytes memory signature) internal view returns (bool) {
        return getSigner(signedHash, signature) == validatorAddress;
    }

}