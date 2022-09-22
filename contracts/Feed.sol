// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


interface ICommonConst {
    function getIngredientNftId(uint8 id) external returns(uint256);
}

interface IPancakeERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) external;
}

interface IIngredientsERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external;
    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
}

interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external;
    function mintBatch(address to, uint[] memory tokenIds, uint[] memory amounts) external;
}

interface ISignatureChecker {
    function checkSignature(bytes32 signedHash, bytes memory signature) external returns(bool);
}

contract Feed is Initializable, OwnableUpgradeable,ERC1155HolderUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable {
    address private pancakeERC1155;
    address private ingredientsERC1155;
    address private bossCardERC1155;
    ICommonConst commonConst;
    address signatureChecker;

    struct FeedStake {
        uint[] tokenIds;
        uint[] amounts;
        uint calories;
        uint256  time;
    }
    mapping(address => FeedStake[]) feedStakes;

    //bosscard info
    struct BossCardStake{
        uint tokenId;
        string traitType;
        uint value;
    }
    mapping(address => BossCardStake) private bossCardStakes;

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256[] amounts, uint256[] tokenIds);
    event RewardClaimed(
        address indexed user,
        uint[] ingredientNftIds,
        uint[] ingredientBftAmounts,
        uint[] bossCards,
        uint[] bossCardAmounts
    );

    function initialize(address _pancakeERC1155, address _ingredientsERC1155, address _bossCardERC1155, address _commonConst, address _signatureChecker) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ERC1155Holder_init();
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
        commonConst = ICommonConst(_commonConst);
        signatureChecker = _signatureChecker;
    }
    function updateContractAddress (address _pancakeERC1155, address _ingredientsERC1155, address _bossCardERC1155, address _commonConst, address _signatureChecker) external onlyOwner{
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
        commonConst = ICommonConst(_commonConst);
        signatureChecker = _signatureChecker;
    }
    function sumOf(uint[] memory self) private pure returns (uint) {
        uint sum = 0;
        for(uint i = 0; i < self.length; i++){
            sum = sum + self[i];
        }
        return sum;
    }

    function stake(uint[] memory tokenIds, uint[] memory amounts, uint calories, bytes memory signature) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        bytes32 message = keccak256(abi.encodePacked(msg.sender,calories));
        bool isSender = ISignatureChecker(signatureChecker).checkSignature(message, signature);
        require(isSender, "Staking: Invalid sender");
        IPancakeERC1155(pancakeERC1155).safeBatchTransferFrom(msg.sender, address(this), tokenIds,amounts,'');
        feedStakes[msg.sender].push(FeedStake({
        tokenIds:tokenIds,
        amounts:amounts,
        calories:calories,
        time: block.timestamp
        }));
        emit Staked(msg.sender, amounts, tokenIds);
    }


    function bossCardStake(uint _tokenId, string memory _traitType, uint _value, bytes memory _signature) external nonReentrant{
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = ISignatureChecker(signatureChecker).checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        bossCardStakes[msg.sender] = BossCardStake({
        tokenId: _tokenId,
        traitType: _traitType,
        value: _value
        });
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function unStakeBoostCard(uint _tokenId) external nonReentrant{
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakes[msg.sender];
    }
    function reveal(uint[] memory _ingredients,  uint[] memory _bossCards, uint[] memory _bossCardAmounts, bytes memory sig) external nonReentrant {
        uint length = sumOf(_ingredients);
        bytes32 message = keccak256(abi.encodePacked(msg.sender,length,sumOf(_bossCards),sumOf(_bossCardAmounts)));
        bool isSender = ISignatureChecker(signatureChecker).checkSignature(message, sig);
        require(isSender, "Invalid Sender");
        uint[] memory ingredientNftIds = new uint[](length);
        uint[] memory ingredientBftAmounts = new uint[](length);
        uint counter = 0;
        for(uint8 i=0;i<_ingredients.length;i++){
            for(uint j=0;j<_ingredients[i];j++){
                uint nftId = commonConst.getIngredientNftId(i+1);
                ingredientNftIds[counter] = nftId;
                ingredientBftAmounts[counter++] = 1;
            }
        }
        // reward ingredients
        IIngredientsERC1155(ingredientsERC1155).mintBatch(msg.sender,ingredientNftIds,ingredientBftAmounts);
        // reward bosscard
        for(uint i=0;i<_bossCards.length;i++){
            if(_bossCards[i]>0){
                IBossCardERC1155(bossCardERC1155).mint(msg.sender,_bossCards[i],_bossCardAmounts[i]);
            }
        }
        // burning staked pancake
        FeedStake[] memory stakes = feedStakes[msg.sender];
        for(uint i =0; i < stakes.length; i++ ){
            IPancakeERC1155(pancakeERC1155).burnBatch(address(this), stakes[i].tokenIds, stakes[i].amounts);
        }
        delete feedStakes[msg.sender];
        emit RewardClaimed(msg.sender, ingredientNftIds,ingredientBftAmounts, _bossCards,_bossCardAmounts);
    }
    function printUserFeeds() external view returns(FeedStake[] memory){
        return feedStakes[msg.sender];
    }

    function printUserBossCardStake() external view returns(BossCardStake memory) {
        return bossCardStakes[msg.sender];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

}