
// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

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
    mapping(uint => string) private Uri;
    mapping(address =>  bool) private _mintApprovals;

    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/QmfQCdUSMGyhZWwfJLP4dABhWysiGPuaoQ9cAJofAhGHJs/{id}.json") {
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
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

    function mintToken(address account, uint256 id, uint256 amount)
    public
    onlyOwner
    {
        _mint(account, id, amount, "");
    }

    function mintBatchToken(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }


    function uri(uint _tokenId) override public pure returns(string memory){
        return string(
            abi.encodePacked(
                "https://ipfs.io/ipfs/QmStLxzjAzk9iudqt1CXaKrEzKCdJCJZq4UoE5ahhbfdhC/",
                Strings.toString(_tokenId),".json"
            )
        );
    }

    function setTokenURI(uint _tokenId, string memory _uri) public onlyOwner{
        require(bytes(Uri[_tokenId]).length == 0, "Cannot set URI twice");
        Uri[_tokenId] = _uri;
    }

    function getTokenCount() public view returns(uint[] memory){
        uint256[] memory tokens = new uint256[](collectionCount);
        for(uint256 i = 0; i < collectionCount; i++ ){
            tokens[i] =  balanceOf(msg.sender, i+1);
        }
        return(tokens);
    }
}
