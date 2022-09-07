// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "hardhat/console.sol";

contract IngredientsERC11155 is ERC1155, ERC1155Burnable, ReentrancyGuard, Ownable, Pausable {
    
    uint collectionCount = 25;
    string private _uri;
    mapping(uint256 => string) private _uris;
    mapping(address =>  bool) private _mintApprovals;
    
    constructor() ERC1155("https://ipfs.io/ipfs/QmStLxzjAzk9iudqt1CXaKrEzKCdJCJZq4UoE5ahhbfdhC/{id}.json") {
    }

    modifier existId(uint _tokenid) {
        require(_tokenid <= collectionCount, "Invalid token id");
        _;
    }

    modifier existIds(uint[] memory _tokenIds) {
        for(uint i=0; i < _tokenIds.length; i++){
            require(_tokenIds[i] <= collectionCount, "Invalid token id");
        } 
        _;
    }

    function setURI(string memory newuri) public onlyOwner {
        _uri = newuri;
    }

    function setMintApprovalForAll(address operator, bool approved) public {
        _mintApprovals[operator] = approved;
    }

    function isMintApprovedForAll(address operator) public view returns (bool) {
        return _mintApprovals[operator];
    }

    // contract mint function
    function mint(address to, uint tokenId, uint amount) public existId(tokenId) {
        require(
            isMintApprovedForAll(msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _mint(to, tokenId, amount, "");

    }

    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public existIds(tokenIds) {
        require(
            isMintApprovedForAll(msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _mintBatch(to, tokenIds, amounts, "");
    }

    // owner mint function
    function mintToken(uint tokenId, uint amount) public onlyOwner existId(tokenId){
        _mint(msg.sender, tokenId, amount, "");
    }

    function batchMintTokens(uint[] memory tokenIds, uint[] memory amounts) public onlyOwner existIds(tokenIds){
        _mintBatch(msg.sender, tokenIds, amounts, "");
    }

    function getTokenCount() public view returns(uint[] memory){
        uint256[] memory tokens = new uint256[](collectionCount);
        for(uint256 i = 0; i < collectionCount; i++ ){
            tokens[i] =  balanceOf(msg.sender, i+1);
        }
        return(tokens);
    }

    function uri(uint256 _tokenid) override public view existId(_tokenid) returns (string memory) {
        if(bytes(_uris[_tokenid]).length > 0){
            return _uris[_tokenid];
        } 
        string memory URI;
        bytes memory tempStringUri = bytes(_uri); 
        if (tempStringUri.length == 0) {
           URI = "https://ipfs.io/ipfs/QmStLxzjAzk9iudqt1CXaKrEzKCdJCJZq4UoE5ahhbfdhC/";
        } else {
            URI = _uri;
        }
        return string(
            abi.encodePacked(
                URI,
                Strings.toString(_tokenid),".json"
            )
        );      
    }
    
    function setTokenSize(uint _collectionCount) public onlyOwner{
        collectionCount = _collectionCount;
    }

    function setTokenUri(uint tokenId_, string memory uri_) public onlyOwner {
        require(bytes(_uris[tokenId_]).length == 0, "Cannot set uri twice");
        _uris[tokenId_] = uri_; 
    }
}