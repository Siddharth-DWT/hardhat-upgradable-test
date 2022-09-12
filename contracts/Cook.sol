// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "hardhat/console.sol";
import "./SignatureChecker.sol";

interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

interface IIngredientsERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
}

interface IPancakeERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function mint(address account, uint256 id, uint256 amount) external;
}

contract Cook is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable, SignatureChecker {
    uint256 stakeIdCount;
    uint256 _timeForReward;
    uint plaincake;
    uint pancake;

    address ingredientsERC1155;
    address bossCardERC1155Address;
    address pancakeERC1155;

    uint[] legendryBoost;
    uint[] shinyBoost;
    uint legendaryIngredientId;
    uint8 basiPancakeRecipeId;

    mapping(address => mapping(uint256 => uint256[]))  userIngredientStakes;
    mapping(address => mapping(uint256 => uint256))  userIngredientStakesTime;
    mapping(address => mapping(uint256 => uint8))  userRecipeClaimTokenId;
    mapping(address => uint256[])  recipeStakes;

    // boss card stake
    struct BossCardStaker{
        uint tokenId;
        uint256  time;
        bool isLegendary;
    }
    mapping(address => BossCardStaker) bossCardStakers;

    function initialize(address _ingredientsERC1155, address _bossCard, address _pancakeERC1155) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        stakeIdCount = 1;
        _timeForReward = 2 hours;
        plaincake = 8;
        pancake = 9;
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155Address = _bossCard;
        pancakeERC1155 =_pancakeERC1155;
        legendaryIngredientId = 25;
        basiPancakeRecipeId = 1;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory)  virtual public returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function isValidStake(uint[] memory tokenIds, uint8 pancakeId) internal view returns (bool){
        bool flag = true;
        uint checkLength = pancakeId == 1? plaincake: pancake;
        if(tokenIds.length == 1 && tokenIds[0] == legendaryIngredientId){
            return true;
        }
        if(tokenIds.length<checkLength){
            flag = false;
        }
        else{
            for(uint i=0;i<tokenIds.length;i++){
                if(tokenIds[i] == 0){
                    flag = false;
                    break;
                }
            }
        }
        return flag;
    }

    function stake(uint256[] memory tokenIds, uint8 claimTokenId) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        require(isValidStake(tokenIds, claimTokenId), "Staking: all ingredients not provided");
        uint256 amount;
        for (uint256 i = 0; i < tokenIds.length; i += 1) {
            amount += 1;
            userIngredientStakes[msg.sender][stakeIdCount].push(tokenIds[i]);
            IIngredientsERC1155(ingredientsERC1155).safeTransferFrom(msg.sender, address(this), tokenIds[i], 1,'');
        }
        userRecipeClaimTokenId[msg.sender][stakeIdCount] = claimTokenId;
        recipeStakes[msg.sender].push(stakeIdCount);
        userIngredientStakesTime[msg.sender][stakeIdCount++] = block.timestamp;
        emit Staked(msg.sender, amount, tokenIds, stakeIdCount);
    }

    function bossCardStake(uint _tokenId, bool _flag, bytes memory _signature) external{
        require(
            bossCardStakers[msg.sender].tokenId == 0,
            "Boost token already stake"
        );
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");

        bossCardStakers[msg.sender] = BossCardStaker({
            tokenId: _tokenId,
            time: block.timestamp,
            isLegendary: _flag
        });
        IBossCardERC1155(bossCardERC1155Address).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function anyClaimInProgress() public  view returns (bool) {
        bool flag = false;
        uint256[] memory stakeIds = recipeStakes[msg.sender];
        for(uint256 i =0; i < stakeIds.length; i++ ){
            if(canAvailClaim(stakeIds[i])){
                flag = true;
                break;
            }
        }
        return flag;
    }

    function bossCardWithdraw(uint _tokenId) external{
        require(
            !anyClaimInProgress(),
            "Claim in progress"
        );
        IBossCardERC1155(bossCardERC1155Address).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }

    function getTimeForReward() public view returns (uint256){
        uint256 rewardTime = _timeForReward;
        if(bossCardStakers[msg.sender].tokenId == 0){
            return rewardTime;
        }
        else{
            rewardTime = rewardTime - _timeForReward/2;
        }
        return rewardTime;
    }

    function canAvailClaim(uint256 _stakeId) public  view returns (bool) {
        if(userIngredientStakesTime[msg.sender][_stakeId] == 0){
            return false;
        }
        uint256 stakedTime = userIngredientStakesTime[msg.sender][_stakeId] +   getTimeForReward();
        return block.timestamp > stakedTime;
    }

    function claimReward(uint256 _stakeId) public {
        uint8 claimId = userRecipeClaimTokenId[msg.sender][_stakeId];
        require(canAvailClaim(_stakeId), "claimReward: stake not available for claim");
        require(claimId != 0, "claimReward: No claim Reward found");
        uint256[] memory tokenIds = userIngredientStakes[msg.sender][_stakeId];
        uint amount = 1;
        if(tokenIds.length ==1 && tokenIds[0]==legendaryIngredientId){
            amount = 3;
            claimId = basiPancakeRecipeId;
        }
        IPancakeERC1155(pancakeERC1155).mint(msg.sender, claimId, 1);
        for(uint i=0; i< tokenIds.length; i++){
            IIngredientsERC1155(ingredientsERC1155).burn(address(this), tokenIds[i], 1);
            console.log("burn token", tokenIds[i]);
        }
        delete userRecipeClaimTokenId[msg.sender][_stakeId];
        delete userIngredientStakes[msg.sender][_stakeId];
        delete userIngredientStakesTime[msg.sender][_stakeId];
        emit RewardClaimed(msg.sender, _stakeId, tokenIds, claimId, 1);
    }

    function printUserIngredientStakes() public view returns(
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        uint256[] memory
    ) {
        uint256[] memory stakeIds = recipeStakes[msg.sender];
        uint256[] memory claimIds = new uint256[](stakeIds.length);
        uint256[] memory stakeTimes = new uint256[](stakeIds.length);
        uint256[] memory claimTimeRemains = new uint256[](stakeIds.length);

        for(uint32 i =0; i < stakeIds.length; i++ ){
            if(userIngredientStakesTime[msg.sender][stakeIds[i]] !=0){
                claimIds[i] =  userRecipeClaimTokenId[msg.sender][stakeIds[i]];
                stakeTimes[i] = userIngredientStakesTime[msg.sender][stakeIds[i]];
                uint whenToClaim = userIngredientStakesTime[msg.sender][stakeIds[i]] + getTimeForReward();
                uint256 remainTime = 0;
                if( whenToClaim > block.timestamp){
                    remainTime = whenToClaim -  block.timestamp;
                }

                claimTimeRemains[i] =  remainTime;
            }
        }
        return(stakeIds, claimIds, stakeTimes, claimTimeRemains);
    }

    function printBossCardStake() public  view returns (uint) {
        return(bossCardStakers[msg.sender].tokenId);
    }

    function setTimeForReward(uint256 timeForReward) public{
        _timeForReward = timeForReward;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    // ========== EVENTS ========== //

    event Staked(address indexed user, uint256 amount, uint256[] tokenIds, uint256 stakeId);
    event RewardClaimed(
        address indexed user,
        uint256 indexed _stakeId,
        uint256[] BurnTokenIds,
        uint256 _claimedRewardId,
        uint256 _amount
    );
}