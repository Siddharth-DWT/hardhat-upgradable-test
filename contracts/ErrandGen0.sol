// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;


import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

interface IIngredientsERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external;
    function mintBatch(address to, uint256[] memory ids, uint256[] memory values) external;
}

interface ICommonConst {
    function revealIngredientNftId() external returns(uint256);
}
interface IErrandBossCardStake {
    function getBossCountClaim(uint256 time) external view returns(uint);
    function getUserStakeBossCardId(address _account) external returns(uint);
}

contract ErrandGen0 is Initializable, ERC1155HolderUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable,ERC721HolderUpgradeable {
    ICommonConst commonConst;
    IErrandBossCardStake errandBossCardStake;
    IERC721Upgradeable private powerPlinsGen0;
    address private bossCardERC1155;
    address private ingredientsERC1155;

   struct RecipeStaker {
        uint[] tokenIds;
        uint256  time;
    }
    mapping(uint256 => RecipeStaker) public recipeStakers;
    mapping(address => uint[]) public userStakeIds;

    mapping(address => mapping(uint256 => uint256))  tokenIdToRewardsClaimed;
    uint256 stakeIdCount;
    uint256  public _timeForReward;

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256 amount, uint256[] tokenIds);
    event RewardClaimed(
        address indexed user,
        uint256 _claimedRewardId,
        uint[] ingredientNftIds
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _powerPlinsGen0, address _ingredientsERC1155,address _bossCard, address _commonConst, address _errandBossCardStake) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __ERC721Holder_init();
        powerPlinsGen0 = IERC721Upgradeable(_powerPlinsGen0);
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCard;
        stakeIdCount = 1;
        _timeForReward = 8 hours;
        commonConst = ICommonConst(_commonConst);
        errandBossCardStake = IErrandBossCardStake(_errandBossCardStake);
        __Ownable_init();
    }

    function setTimeForReward(uint256 timeForReward) public onlyOwner {
        _timeForReward = timeForReward;
    }
    function indexOf(uint[] memory self, uint value) internal pure returns (int) {
        for (uint i = 0; i < self.length; i++)if (self[i] == value) return int(i);
        return -1;
    }

    function stake(uint256[] memory tokenIds) external nonReentrant{
        require(tokenIds.length != 0, "Errand:: invalid ids");
        for (uint i = 0; i < tokenIds.length; i++) {
            powerPlinsGen0.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
        recipeStakers[stakeIdCount] = RecipeStaker({
            tokenIds:tokenIds,
            time: block.timestamp
        });
        userStakeIds[msg.sender].push(stakeIdCount);
        stakeIdCount++;

        emit Staked(msg.sender, tokenIds.length, tokenIds);
    }

    function unStake(uint256 _stakeId) public nonReentrant {
        require(indexOf(userStakeIds[msg.sender],_stakeId) >=0,"Errand: not valid unstake id");
        RecipeStaker memory staker = recipeStakers[_stakeId];

        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, staker.time, staker.tokenIds.length);
        require( _numberToClaim == 0,"Errand:: rewards left unclaimed!");

        uint256 amount = staker.tokenIds.length;
        for (uint256 i = 0; i < amount; i++) {
            powerPlinsGen0.safeTransferFrom(address(this),msg.sender, staker.tokenIds[i]);
        }
        delete tokenIdToRewardsClaimed[msg.sender][_stakeId];
        delete recipeStakers[_stakeId];
        for(uint i=0 ; i < userStakeIds[msg.sender].length; i++) {
            if(userStakeIds[msg.sender][i] == _stakeId){
                while ( i < userStakeIds[msg.sender].length - 1) {
                    userStakeIds[msg.sender][i] = userStakeIds[msg.sender][i+1];
                    i++;
                }
                userStakeIds[msg.sender].pop();
            }
        }
        emit Withdrawn(msg.sender, amount, staker.tokenIds);
    }

 /*   function bossCardStake(uint _tokenId) external nonReentrant {
        require(
            indexOf(legendaryBoost,_tokenId) > 0 || indexOf(shinyBoost,_tokenId) >=0,
            "Not valid boost token for stake"
        );
        require(
            bossCardStakers[msg.sender].tokenId ==0,
            "Boost token already stake"
        );
        bossCardStakers[msg.sender].tokenId = _tokenId;
        bossCardStakers[msg.sender].time = block.timestamp;
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }*/

  /*  function bossCardWithdraw(uint _tokenId) external nonReentrant{
        require(!anyClaimInProgress(), "Claim in progress");
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }*/

    /*function getBossCountClaim(uint256 stakedTime) public view returns(uint){
        uint bossCount = 0;
        if(bossCardStakers[msg.sender].tokenId !=0){
            uint bossNumber = 1;
            if(indexOf(shinyBoost,bossCardStakers[msg.sender].tokenId) > 0){
                bossNumber = 2;
            }
            bossCount = (((block.timestamp - stakedTime ) / (_timeForReward * 3))) * bossNumber;
        }
        return bossCount;

    }*/
    function numberOfRewardsToClaim(uint256 _stakeId, uint256 stakeTime , uint tokens) public  view returns (uint) {
        uint256 stakedTime = stakeTime +  (tokenIdToRewardsClaimed[msg.sender][_stakeId] * _timeForReward);
        if(stakedTime == 0) {
            return 0;
        }
        uint count = (block.timestamp - stakedTime)  / _timeForReward;
        uint bossCount = errandBossCardStake.getBossCountClaim(stakedTime);
        uint totalCount = count > 0 ? (count* tokens) + bossCount : 0;
        return totalCount;
    }

    function claimReward(uint256 _stakeId) public nonReentrant {
        require(indexOf(userStakeIds[msg.sender],_stakeId) >=0,"Errand: not valid unstake id");
        RecipeStaker memory staker = recipeStakers[_stakeId];
        uint256[] memory tokenIds = staker.tokenIds;
        require(recipeStakers[_stakeId].tokenIds.length != 0, "claimReward: No token Found for claim");

        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, recipeStakers[_stakeId].time,1);
        require(_numberToClaim != 0, "claimReward: No claim pending");

        _claimReward(_numberToClaim*tokenIds.length, _stakeId);
        uint256 lastClaimTime = recipeStakers[_stakeId].time +  (tokenIdToRewardsClaimed[msg.sender][_stakeId] * _timeForReward);
        uint bossCount = errandBossCardStake.getBossCountClaim(lastClaimTime);
        tokenIdToRewardsClaimed[msg.sender][_stakeId] += (_numberToClaim - bossCount);
    }


    function _claimReward(uint _numClaim, uint _stakeId) private {
        uint[] memory ingredientNftIds = new uint[](_numClaim);
        uint[] memory amounts = new uint[](_numClaim);
        for(uint i = 0; i<_numClaim;i++){
            uint nftId = commonConst.revealIngredientNftId();
            ingredientNftIds[i] = nftId;
            amounts[i] = 1;
        }
        IIngredientsERC1155(ingredientsERC1155).mintBatch(msg.sender,ingredientNftIds, amounts);
        emit RewardClaimed(msg.sender, _stakeId, ingredientNftIds);
    }

    function anyClaimInProgress() public  view returns (bool) {
        bool flag = false;
        uint[] memory stakeIds = userStakeIds[msg.sender];
        for(uint256 i =0; i < stakeIds.length; i++ ){
            RecipeStaker memory staker = recipeStakers[stakeIds[i]];
            uint256 count = numberOfRewardsToClaim(stakeIds[i], staker.time,staker.tokenIds.length);
            if(count > 0){
                flag = true;
                break;
            }
        }
        return flag;
    }

    function printUserClaims() public  view returns (uint256[] memory, uint[] memory) {
        uint[] memory stakeIds = userStakeIds[msg.sender];
        uint256[] memory claims = new uint256[](stakeIds.length);
        for(uint256 i =0; i < stakeIds.length; i++ ){
            RecipeStaker memory staker = recipeStakers[stakeIds[i]];
            claims[i] =  numberOfRewardsToClaim(stakeIds[i], staker.time,staker.tokenIds.length);
        }

        return(stakeIds, claims);
    }

    function printUserStakes() public  view returns (uint[] memory,RecipeStaker[] memory) {
        uint[] memory stakeIds = userStakeIds[msg.sender];
        RecipeStaker[] memory stakes = new RecipeStaker[](stakeIds.length);
        for(uint256 i =0; i < stakeIds.length; i++ ){
            stakes[i] = recipeStakers[stakeIds[i]];
        }
        return(stakeIds, stakes);
    }

    /*function printBossCardStake() public  view returns (uint) {
        return(bossCardStakers[msg.sender].tokenId);
    }*/

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
