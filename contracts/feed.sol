// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SignatureChecker.sol";
import "hardhat/console.sol";


interface IPancakeERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
}

interface IIngredientsERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external returns(address);
}

interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external returns(address);
}


contract Feed is ReentrancyGuard, Ownable, Pausable, SignatureChecker, Initializable, UUPSUpgradeable{
    
    uint nonce;
    uint256  _timeForReward;
    address private pancakeERC1155;
    address private ingredientsERC1155;
    address private bossCardERC1155;
    address private _owner;

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
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
        nonce = 1;
        _timeForReward = 24 hours;
        _owner = msg.sender;
    }

    function updateContractAdress (address _pancakeERC1155, address _ingredientsERC1155, address _bossCardERC1155) public onlyOwner{
        pancakeERC1155 = _pancakeERC1155;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
    }

    function owner() public view override virtual returns (address) {
        return _owner;
    }

    function setTimeForReward(uint256 timeForReward) public{
        _timeForReward = timeForReward;
    }

    function stake(uint[] memory tokenIds, uint[] memory amounts, uint calories, bytes memory _signature) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        bytes32 message = keccak256(abi.encodePacked(tokenIds, amounts, calories, msg.sender));
       
        bool isSender = checkSignature(message, _signature);
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
        bytes32 message = keccak256(abi.encodePacked(_tokenId, _traitType, _value, msg.sender));
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
        bytes32 message = keccak256(abi.encodePacked(_tokenId, msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }

    function reveal(uint[] memory ingredients,  uint _bossCard, uint _shinyCard, bytes memory _signature) public {
        bytes32 message = keccak256(abi.encodePacked(ingredients, _bossCard, _shinyCard, msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        for(uint i=0;i<ingredients.length;i++){
            if(ingredients[i]>0){
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

                for(uint j=0;j<ingredients[i];j++){
                    uint nftId = i==4?25:random(start,end);
                    IIngredientsERC1155(ingredientsERC1155).mint(msg.sender,nftId,1);
                }
            }
        }
        IBossCardERC1155(bossCardERC1155).mint(msg.sender,_bossCard,1);
        IBossCardERC1155(bossCardERC1155).mint(msg.sender,_shinyCard,1);
        delete feedStakers[msg.sender];
        //emit RewardClaimed(msg.sender,  _stakeId, _claimedRewardId, _numClaim);
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
        uint256 indexed _tokenId,
        uint256 _claimedRewardId,
        uint256 _amount
    );
}
