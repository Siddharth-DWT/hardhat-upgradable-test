// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract Gen1ERC1155 is ERC1155, Ownable, ReentrancyGuard {
    uint collectionCount = 510;
    string private _uri;
    mapping(uint256 => string) private _uris;
    mapping(address =>  bool) private _mintApprovals;

    constructor(string memory _baseUri) ERC1155(string(
            abi.encodePacked(
                _baseUri,
                "{id}.json"
            )
        )) {
        _uri = _baseUri;
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

    function setTokenUri(uint tokenId_, string memory uri_) public onlyOwner {
        require(bytes(_uris[tokenId_]).length == 0, "Cannot set uri twice");
        _uris[tokenId_] = uri_;
    }

    function setMintApprovalForAll(address operator, bool approved) public {
        _mintApprovals[operator] = approved;
    }

    function isMintApprovedForAll(address operator) public view returns (bool) {
        return _mintApprovals[operator];
    }

    // contract mint function
    function mint(address to, uint tokenId, uint amount) public existId(tokenId){
        require(
            isMintApprovedForAll(msg.sender) || owner() == msg.sender,
            "ERC1155: caller is not owner nor approved"
        );
        _mint(to, tokenId, amount, "");
    }

    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public existIds(tokenIds) {
        require(
            isMintApprovedForAll(msg.sender) || owner() == msg.sender,
            "ERC1155: caller is not owner nor approved"
        );
        _mintBatch(to, tokenIds, amounts, "");
    }

    function setTokenSize(uint _collectionCount) public onlyOwner{
        collectionCount = _collectionCount;
    }
    function getTokenCount() public view returns(uint[] memory){
        uint256[] memory tokens = new uint256[](collectionCount);
        for(uint256 i = 0; i < collectionCount; i++ ){
            tokens[i] =  balanceOf(msg.sender, i+1);
        }
        return(tokens);
    }
    function uri(uint256 _tokenId) override public view existId(_tokenId) returns (string memory) {
        if(bytes(_uris[_tokenId]).length > 0){
            return _uris[_tokenId];
        }
        return string(
            abi.encodePacked(
                _uri,
                Strings.toString(_tokenId),".json"
            )
        );
    }

}