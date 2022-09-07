// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SignatureChecker.sol";
import "hardhat/console.sol";

interface IPancakeERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
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

contract Feed is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable, SignatureChecker {
    uint nonce;
    uint256  _timeForReward;

    address private pancakeERC1155;
    address private ingredientsERC1155;
    address private bossCardERC1155;

    struct FeedStaker {
        uint[] tokenIds;
        uint[] amounts;
        uint calories;
        uint256  time;
    }
    mapping(address => FeedStaker[]) feedStakers;

    //bosscard info
    struct BossCardStakers{
        uint tokenId;
        string traitType;
        uint value;
    }
    mapping(address => BossCardStakers) private bossCardStakers;

    function random(uint from, uint to) internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % to;
        randomnumber = from + randomnumber ;
        nonce++;
        return randomnumber;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function initialize(address _pancakeERC1155, address _ingredientsERC1155, address _bossCardERC1155) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __SigChecker_init();
        nonce = 1;
        _timeForReward = 24 hours;
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
    }

    function updateContractAdress (address _pancakeERC1155, address _ingredientsERC1155, address _bossCardERC1155) public onlyOwner{
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
    }

    function setTimeForReward(uint256 timeForReward) public{
        _timeForReward = timeForReward;
    }

    function stake(uint[] memory tokenIds, uint[] memory amounts, uint calories, bytes memory signature) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, signature);
        require(isSender, "Staking: Invalid sender");
        uint256 amount;
        for (uint256 i = 0; i < tokenIds.length; i += 1) {
            amount += 1;
            IPancakeERC1155(pancakeERC1155).safeTransferFrom(msg.sender, address(this), tokenIds[i],amounts[i],'');
        }
        feedStakers[msg.sender].push(FeedStaker({
        tokenIds:tokenIds,
        amounts:amounts,
        calories:calories,
        time: block.timestamp
        }));
        emit Staked(msg.sender, amount, tokenIds);
    }


    function bossCardStake(uint _tokenId, string memory _traitType, uint _value, bytes memory _signature) external{
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        bossCardStakers[msg.sender] = BossCardStakers({
        tokenId: _tokenId,
        traitType: _traitType,
        value: _value
        });
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function unStakeBoostCard(uint _tokenId, bytes memory _signature) external{
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }

    function reveal(uint[] memory _ingredients,  uint[] memory _bossCards, uint[] memory _bossCardAmounts, bytes memory _signature) public {
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid Sender");
        uint length = 0;
        for(uint i= 0;i<_ingredients.length;i++){
            length = length + _ingredients[i];
        }
        uint[] memory ingredientNftIds = new uint[](length);
        uint[] memory ingredientBftAmounts = new uint[](length);
        uint counter = 0;
        for(uint i=0;i<_ingredients.length;i++){
            if(_ingredients[i]>0){
                uint start =0;
                uint end = 0;
                if(i == 0){
                    start = 1;
                    end = 5;
                }
                else if(i == 1 ){
                    start = 6;
                    end = 8;
                }
                else if(i== 2 ){
                    start = 9;
                    end = 19;
                }
                else if(i == 3 ){
                    start = 20;
                    end = 24;
                }

                for(uint j=0;j<_ingredients[i];j++){
                    uint nftId = i==4?25:random(start,end);
                    ingredientNftIds[counter] =  nftId;
                    ingredientBftAmounts[counter++] = 1;
                }
            }
        }
        for(uint i=0;i<_bossCards.length;i++){
            if(_bossCardAmounts[i] > 0) {
            }
        }
        IIngredientsERC1155(ingredientsERC1155).mintBatch(msg.sender,ingredientNftIds,ingredientBftAmounts);
        IBossCardERC1155(bossCardERC1155).mintBatch(msg.sender,_bossCards,_bossCardAmounts);
        FeedStaker[] memory stakers = feedStakers[msg.sender];
        for(uint32 i =0; i < stakers.length; i++ ){
            IPancakeERC1155(pancakeERC1155).burnBatch(address(this), stakers[i].tokenIds, stakers[i].amounts);
        }
        delete feedStakers[msg.sender];
        emit RewardClaimed(msg.sender, ingredientNftIds,ingredientBftAmounts, _bossCards,_bossCardAmounts);
    }

    function getTimeForReward() public view returns(uint256){
        return _timeForReward;
    }

    function printUserFeeds() public view returns(FeedStaker[] memory){
        return feedStakers[msg.sender];
    }

    function printUserBossCardStake() public view returns(BossCardStakers memory) {
        return bossCardStakers[msg.sender];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256 amount, uint256[] tokenIds);
    event RewardClaimed(
        address indexed user,
        uint[] ingredientNftIds,
        uint[] ingredientBftAmounts,
        uint[] bossCards,
        uint[] bossCardAmounts
    );
}
