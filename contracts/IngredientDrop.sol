// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

interface ISignatureChecker {
    function checkSignature(bytes32 signedHash, bytes memory signature) external returns(bool);
}

interface IIngredientsERC1155{
    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
}

contract IngredientDrop is Ownable, Pausable{

    address signatureChecker;
    address private token;
    uint8 private noOfToken = 8;

    constructor(address _token, address _signatureChecker){
        token = _token;
        signatureChecker = _signatureChecker;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _requireNotPaused() internal view virtual override {
        require(!paused(), "Pausable: claim is disabled");
    }

    function _requirePaused() internal view virtual override {
        require(paused(), "Pausable: claim is enabled");
    }

    function setNoOfToken(uint8 _noOfToken) public onlyOwner{
        noOfToken = _noOfToken;
    }

    function claim(uint _noOfClaim, bytes memory _signature) public whenNotPaused  {
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