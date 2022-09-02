// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "hardhat/console.sol";


contract PancakeNftERC11155 is ERC1155, ERC1155Burnable,ReentrancyGuard, Ownable, Pausable {

    mapping (uint256 => string) private _uris;
    uint collectionCount = 19;
    mapping(address =>  bool) private _mintApprovals;

    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmfQCdUSMGyhZWwfJLP4dABhWysiGPuaoQ9cAJofAhGHJs/{id}.json") {
    }

    function setMintApprovalForAll(address operator, bool approved) public {
        _mintApprovals[operator] = approved;
    }

    function isMintApprovedForAll(address operator) public view returns (bool) {
        return _mintApprovals[operator];
    }

    // contract mint function
    function mint(address to, uint tokenId, uint amount) public{
        require(
            isMintApprovedForAll(msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _mint(to, tokenId, amount, "");

    }

    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) public {
        require(
            isMintApprovedForAll(msg.sender),
            "ERC1155: caller is not owner nor approved"
        );
        _mintBatch(to, tokenIds, amounts, "");
    }


    function batchMintToken(address to, uint[] memory tokenIds, uint[] memory amounts) public onlyOwner{
        _mintBatch(to, tokenIds, amounts, "");
    }

    function mintToken(uint tokenId, uint amount) public onlyOwner{
        _mint(msg.sender, tokenId, amount, "");
    }

    function getTokenCount() public view returns(uint[] memory){
        uint256[] memory tokens = new uint256[](collectionCount);
        for(uint256 i = 0; i < collectionCount; i++ ){
            tokens[i] =  balanceOf(msg.sender, i+1);
        }
        return(tokens);
    }

    function uri(uint256 _tokenid) override public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "https://gateway.pinata.cloud/ipfs/QmfQCdUSMGyhZWwfJLP4dABhWysiGPuaoQ9cAJofAhGHJs/",
                Strings.toString(_tokenid),".json"
            )
        );
    }

    function setTokenUri(uint256 tokenId, string memory _uri) public onlyOwner {
        require(bytes(_uris[tokenId]).length == 0, "Cannot set uri twice");
        _uris[tokenId] = _uri;
    }
}