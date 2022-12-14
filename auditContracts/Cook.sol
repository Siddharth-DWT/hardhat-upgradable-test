// SPDX-License-Identifier: MIT
pragma solidity >=0.8.9 <0.9.0;
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
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
    function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function burnBatch(address account, uint[] memory  id, uint[] memory value) external;
}

interface IPancakeERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function mint(address account, uint256 id, uint256 amount) external;
}

contract Cook is Initializable, OwnableUpgradeable, ERC1155HolderUpgradeable,ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable, SignatureChecker {
    address public ingredientsERC1155;
    address public  bossCardERC1155Address;
    address public  pancakeERC1155;

    uint256  stakeIdCount;
    uint256 public timeForReward;
    uint[]  plainCakeCookIds;
    uint  legendaryIngredientId;
    uint8 plainPancakeId;

    struct StakeIngredient{
        uint[] ids;
        uint[] amounts;
        uint pancakeId;
    }

    mapping(address => mapping(uint256 => StakeIngredient[]))  userIngredientStakes;
    mapping(address => mapping(uint256 => uint256))  userIngredientStakesTime;
    mapping(address => uint256[])  recipeStakes;

    uint[] legendaryBoost;
    uint[] shinyBoost;

    // boss card stake
    struct BossCardStake{
        uint tokenId;
        uint256  time;
    }
    mapping(address => BossCardStake) bossCardStakes;


    // ========== EVENTS ========== //
    event Staked(address indexed user, StakeIngredient[]);
    event RewardClaimed(
        address indexed user,
        uint256 indexed _stakeId,
        uint[] pancakeIds,
        uint[] amounts
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _ingredientsERC1155, address _bossCard, address _pancakeERC1155) public initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __ERC1155Holder_init();
        stakeIdCount = 1;
        timeForReward = 2 hours;
        plainCakeCookIds=[1,2,3,4,5,6,7,8];
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155Address = _bossCard;
        pancakeERC1155 =_pancakeERC1155;
        legendaryIngredientId = 25;
        plainPancakeId = 1;
        legendaryBoost =[1,23,53];
        shinyBoost = [2,24,54];
        
    }

    function isLegendaryBoost(uint tokenId) internal view  returns (bool){
        bool found= false;
        for (uint i=0; i<legendaryBoost.length; i++) {
            if(legendaryBoost[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }
    function isShinyBoost(uint tokenId) internal view returns (bool){
        bool found= false;
        for (uint i=0; i<shinyBoost.length; i++) {
            if(shinyBoost[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

   /* function onERC1155Received(address, address, uint256, uint256, bytes memory)  virtual public returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }*/

    function isValidStake(StakeIngredient[] memory _stakeIngredients) internal view returns (bool){
        bool flag = true;
        for(uint i=0;i<_stakeIngredients.length;i++){
            StakeIngredient memory si = _stakeIngredients[i];
            if(si.ids.length == plainCakeCookIds.length && si.pancakeId != plainPancakeId){
                flag = false;
            }
            else if(si.ids.length == 1 && si.ids[0] == legendaryIngredientId && si.pancakeId != plainPancakeId){
                flag = false;
            }
            else if(si.ids.length != si.amounts.length){
                flag = false;
            }
            for(uint j=0;j<si.ids.length;j++){
              if(si.ids[j] == 0 || si.amounts[j] ==0){
                  flag= false;
              }
            }
        }
        return flag;
    }

    function stake(StakeIngredient[] memory _stakeIngredients) external nonReentrant whenNotPaused{
        require(_stakeIngredients.length != 0, "Staking: No ingredientIds provided");
        require(isValidStake(_stakeIngredients), "Staking: all ingredients not provided");

        for (uint256 i = 0; i < _stakeIngredients.length; i += 1) {
            StakeIngredient memory si = _stakeIngredients[i];
            IIngredientsERC1155(ingredientsERC1155).safeBatchTransferFrom(msg.sender, address(this), si.ids, si.amounts,'');
            userIngredientStakes[msg.sender][stakeIdCount]
            .push(StakeIngredient({
                ids:si.ids,
                amounts:si.amounts,
                pancakeId:si.pancakeId
            }));
        }
        recipeStakes[msg.sender].push(stakeIdCount);
        userIngredientStakesTime[msg.sender][stakeIdCount++] = block.timestamp;
        emit Staked(msg.sender,_stakeIngredients);
    }

    function bossCardStake(uint _tokenId) external{
        require(
            bossCardStakes[msg.sender].tokenId == 0,
            "Boost token already stake"
        );
        require(
            isLegendaryBoost(_tokenId) || isShinyBoost(_tokenId),
            "Not valid boost token for stake"
        );
        bossCardStakes[msg.sender].tokenId = _tokenId;
        bossCardStakes[msg.sender].time= block.timestamp;
        IBossCardERC1155(bossCardERC1155Address).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function bossCardWithdraw(uint _tokenId) external nonReentrant{
        require(
            !anyClaimInProgress(),
            "Claim in progress"
        );
        IBossCardERC1155(bossCardERC1155Address).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakes[msg.sender];
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
    function setTimeForReward(uint256 _timeForReward) public onlyOwner{
        timeForReward = _timeForReward;
    }
    function getTimeForReward() public view returns (uint256){
        if(bossCardStakes[msg.sender].tokenId == 0){
            return timeForReward;
        }
        uint8 timeReduceBy =2;
        if(isShinyBoost(bossCardStakes[msg.sender].tokenId)){
            timeReduceBy = 4;
        }
        return timeForReward - timeForReward/timeReduceBy;
    }

    function canAvailClaim(uint256 _stakeId) public  view returns (bool) {
        if(userIngredientStakesTime[msg.sender][_stakeId] == 0){
            return false;
        }
        uint256 stakedTime = userIngredientStakesTime[msg.sender][_stakeId] +   getTimeForReward();
        return block.timestamp > stakedTime;
    }

    function claimReward(uint256 _stakeId) external {
        require(canAvailClaim(_stakeId), "claimReward: stake not available for claim");
        StakeIngredient[] memory sis = userIngredientStakes[msg.sender][_stakeId];
        uint[] memory amounts = new uint[](sis.length);
        uint[] memory  pancakeIds = new uint[](sis.length);
        for(uint i=0;i<sis.length;i++){
            uint amount = 1;
            if(sis[i].ids.length ==1 && sis[i].ids[0]==legendaryIngredientId){
                amount = 3;
            }
            amounts[i] = amount;
            pancakeIds[i] = sis[i].pancakeId;
            IPancakeERC1155(pancakeERC1155).mint(msg.sender, sis[i].pancakeId, amount);
            IIngredientsERC1155(ingredientsERC1155).burnBatch(address(this), sis[i].ids, sis[i].amounts);
            delete userIngredientStakes[msg.sender][_stakeId];
            delete userIngredientStakesTime[msg.sender][_stakeId];
        }
        emit RewardClaimed(msg.sender, _stakeId, pancakeIds, amounts);
    }

    function printUserIngredientStakes() external view returns(
        uint[] memory,
        uint[] memory,
        uint[] memory,
        uint[] memory,
        uint[] memory
    ) {
        uint[] memory stakeIds = recipeStakes[msg.sender];
        uint[] memory claimIds = new uint256[](stakeIds.length);
        uint[] memory stakeTimes = new uint256[](stakeIds.length);
        uint[] memory claimTimeRemains = new uint256[](stakeIds.length);
        uint[] memory claimAmounts = new uint256[](stakeIds.length);
        for(uint32 i =0; i < stakeIds.length; i++ ){
            if(userIngredientStakesTime[msg.sender][stakeIds[i]] !=0){
                uint amount = 1;
                if(userIngredientStakes[msg.sender][stakeIds[i]][0].ids.length ==1 && userIngredientStakes[msg.sender][stakeIds[i]][0].ids[0]==legendaryIngredientId){
                    amount = 3;
                }
                claimIds[i] =  userIngredientStakes[msg.sender][stakeIds[i]][0].pancakeId;
                claimAmounts[i] = userIngredientStakes[msg.sender][stakeIds[i]].length * amount;
                stakeTimes[i] = userIngredientStakesTime[msg.sender][stakeIds[i]];
                uint whenToClaim = userIngredientStakesTime[msg.sender][stakeIds[i]] + getTimeForReward();
                uint256 remainTime = 0;
                if( whenToClaim > block.timestamp){
                    remainTime = whenToClaim -  block.timestamp;
                }
                claimTimeRemains[i] =  remainTime;
            }
        }
        return(stakeIds, claimIds, stakeTimes, claimTimeRemains, claimAmounts);
    }

    function printBossCardStake() external  view returns (uint) {
        return(bossCardStakes[msg.sender].tokenId);
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

}