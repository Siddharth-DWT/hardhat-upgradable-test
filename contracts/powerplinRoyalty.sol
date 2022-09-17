// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

//the rarible dependency files are needed to setup sales royalties on Rarible 
import "@rarible/royalties/contracts/impl/RoyaltiesV2Impl.sol";
import "@rarible/royalties/contracts/LibPart.sol";
import "@rarible/royalties/contracts/LibRoyaltiesV2.sol";


contract PowerPlinsGen0ERC721Royalty is ERC721A, Ownable, ReentrancyGuard, RoyaltiesV2Impl {

    //using Strings for uint256;
    using StringsUpgradeable for uint256;

    bytes32 public merkleRoot;
    mapping(address => uint) public whitelistClaimed;

    uint public maxWhitelistMintPerUser = 3;
    uint public maxMintAmountPerUser;

    string public uriPrefix = '';
    string public uriSuffix = '.json';
    string public hiddenMetadataUri;

    uint256 public cost = 0.030 ether;
    uint256 public presaleCost = 0.015 ether;

    uint256 public maxSupply;

    bool public paused = false;
    bool public whitelistMintEnabled = true;
    bool public revealed = false;
    mapping(address => bool) public whitelisted;
    mapping(address => bool) public presaleWallets;
    address public beneficiary;
    uint adminDefaultMint=90;
    //bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _cost,
        uint256 _maxSupply,
        string memory _hiddenMetadataUri,
        bytes32 _merkleRoot
    ) ERC721A(_tokenName, _tokenSymbol) {
        setCost(_cost);
        maxSupply = _maxSupply;
        setHiddenMetadataUri(_hiddenMetadataUri);
        beneficiary = _msgSender();
        ownerMint(_msgSender(),adminDefaultMint);
        merkleRoot = _merkleRoot;
    }

    function mint(uint256 _mintAmount, bytes32[] calldata _merkleProof) public payable nonReentrant{
        require(!paused, 'The contract is paused!');
        uint256 supply = totalSupply();
        require(_mintAmount > 0);
        require(supply + _mintAmount <= maxSupply);
        if(whitelistMintEnabled){
            bytes32 leaf = keccak256(abi.encodePacked(_msgSender()));
            require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');
            require(msg.value >= presaleCost * _mintAmount,"Insufficient funds");
            require(maxWhitelistMintPerUser >= (whitelistClaimed[_msgSender()] + _mintAmount), 'Insufficient mints left');
            whitelistClaimed[_msgSender()] = whitelistClaimed[_msgSender()] + _mintAmount;
            _safeMint(_msgSender(), _mintAmount);
        }
        else{
            require(msg.value >= cost * _mintAmount,"Insufficient funds");
            _safeMint(_msgSender(), _mintAmount);
        }
    }
    
    function ownerMint(address to, uint256 amount) public onlyOwner {
        _internalMint(to, amount);
    }

    function _internalMint(address _to, uint256 _mintAmount) private {
        uint256 supply = totalSupply();
        require(supply + _mintAmount <= maxSupply);
        _safeMint(_to, _mintAmount);
    }
    function setMaxWhitelistMintPerUser(uint _maxAmount) public onlyOwner{
        maxWhitelistMintPerUser = _maxAmount;
    }

    function setMaxMintAmountPerUser(uint256 _maxMintAmountPerUser) public onlyOwner {
        maxMintAmountPerUser = _maxMintAmountPerUser;
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setPresaleCost(uint256 _cost) public onlyOwner {
        presaleCost = _cost;
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory ownedTokenIds = new uint256[](ownerTokenCount);
        uint256 currentTokenId = _startTokenId();
        uint256 ownedTokenIndex = 0;
        address latestOwnerAddress;

        while (ownedTokenIndex < ownerTokenCount && currentTokenId < _currentIndex) {
            TokenOwnership memory ownership = _ownerships[currentTokenId];

            if (!ownership.burned) {
                if (ownership.addr != address(0)) {
                    latestOwnerAddress = ownership.addr;
                }

                if (latestOwnerAddress == _owner) {
                    ownedTokenIds[ownedTokenIndex] = currentTokenId;

                    ownedTokenIndex++;
                }
            }

            currentTokenId++;
        }

        return ownedTokenIds;
    }

    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

    function addPresaleUser(address _user) public onlyOwner {
        presaleWallets[_user] = true;
    }

    function tokenURI(uint256 _tokenId) public view  override returns (string memory) {
        require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

        if (revealed == false) {
            return hiddenMetadataUri;
        }

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
    }

    function setRevealed(bool _state) public onlyOwner {
        revealed = _state;
    }

    function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
        hiddenMetadataUri = _hiddenMetadataUri;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function setPaused(bool _state) public onlyOwner {
        paused = _state;
    }

    function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function setWhitelistMintEnabled(bool _state) public onlyOwner {
        whitelistMintEnabled = _state;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        beneficiary = _beneficiary;
    }

    function setRoyalties(address _royalties) public onlyOwner {
        royalties = _royalties;
    }

    function withdraw() public onlyOwner {
        payable(beneficiary).transfer(address(this).balance);
    }

    function getTotalSupply() external view returns(uint supply){
        return totalSupply();
    }

    function _baseURI() internal view  override returns (string memory) {
        return uriPrefix;
    }
    
    function setRoyalties(uint _tokenId, address payable _royaltiesRecipientAddress, uint96 _percentageBasisPoints) public onlyOwner {
        LibPart.Part[] memory _royalties = new LibPart.Part[](1);
        _royalties[0].value = _percentageBasisPoints;
        _royalties[0].account = _royaltiesRecipientAddress;
        _saveRoyalties(_tokenId, _royalties);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        LibPart.Part[] memory _royalties = royalties[_tokenId];
        if(_royalties.length > 0) {
            return (_royalties[0].account, (_salePrice * _royalties[0].value) / 10000);
        }
        return (address(0), 0);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A) returns (bool) {
        if(interfaceId == LibRoyaltiesV2._INTERFACE_ID_ROYALTIES) {
            return true;
        }
        if(interfaceId == type(IERC2981).interfaceId) {
          return true;
        }
        return super.supportsInterface(interfaceId);
    }

}
