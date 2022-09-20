// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface ISignatureChecker {
    function checkSignature(bytes32 signedHash, bytes memory signature) external returns(bool);
}

interface IIngredientsERC1155{
    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
}

contract Drop is Ownable{

    address signatureChecker;
    address private token;
    uint8 private noOfToken = 8;

    constructor(address _token, address _signatureChecker){
        token = _token;
        signatureChecker = _signatureChecker;
    }

    function setNoOfToken(uint8 _noOfToken) public onlyOwner{
        noOfToken = _noOfToken;
    }

    function claim(uint _noOfClaim, bytes memory _signature) public {
        uint[] memory ingredientIds = new uint[](noOfToken);
        uint[] memory amounts = new uint[](noOfToken);
        bytes32 message = keccak256(abi.encodePacked(msg.sender, _noOfClaim));
        bool isSender = ISignatureChecker(signatureChecker).checkSignature(message, _signature);
        require(isSender, "Claim: Invalid sender");
        require(_noOfClaim != 0, "Claim: No claimReward found");
    
        for(uint i = 0; i < ingredientIds.length; i++){
            ingredientIds[i] = i+1;
            amounts[i] = 1 * _noOfClaim;
        }   
        IIngredientsERC1155(token).mintBatch(msg.sender, ingredientIds, amounts);
    }
}