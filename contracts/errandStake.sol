// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SignatureChecker.sol";

import "hardhat/console.sol";

interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

interface IIngredientsERC1155{
    //function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external;
}
 
contract ErrandStake is Initializable, ERC721HolderUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable, SignatureChecker {
    uint collectionCount;
    uint nonce;
    uint256 stakeIdCount;
    uint256  _timeForReward;

    IERC721Upgradeable private powerPlinsGen0;
    address private bossCardERC1155;
    address private ingredientsERC1155;
   
    struct CategoryGen0 {
        uint from;
        uint to;
        uint[]  tokenIds;
    }

    uint[] cat1;
    uint[] cat2;
    uint[] cat3;
    uint[] cat4;

    uint[] legendryBoost;
    uint[] shinyBoost;

    CategoryGen0 range_gen0_1;
    CategoryGen0 range_gen0_2;
    CategoryGen0 range_gen0_3;
    CategoryGen0 range_gen0_4;

    struct BossCardStaker{
        uint tokenId;
        uint256  time;
    }
    struct RecipeStaker {
        uint256 stakeId;
        uint[] tokenIds;
        uint256  time;
    }
    mapping(address => BossCardStaker)  bossCardStakers;
    mapping(address => uint)  userBoostCount;

    mapping(address => RecipeStaker[]) recipeStakers;
    mapping(address => mapping(uint256 => uint256))  tokenIdToRewardsClaimed;
    uint256 totalTokenStake;

    function random(uint from, uint to) internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % to;
        randomnumber = from + randomnumber ;
        nonce++;
        return randomnumber;
    }

    function isLegendryBoost(uint tokenId) internal view  returns (bool){
        bool found= false;
        for (uint i=0; i<legendryBoost.length; i++) {
            if(legendryBoost[i]==tokenId){
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

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function findIndex(uint value) internal view returns(uint) {
        uint i = 0;
        RecipeStaker[] memory stakers = recipeStakers[msg.sender];
        while (stakers[i].stakeId != value) {
            i++;
        }
        return i;
    }

    function initialize(address _powerPlinsGen0, address _ingredientsERC1155, address _bossCard) external initializer {
        
        __ERC721Holder_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        __SigChecker_init();
        collectionCount = 25;
        nonce = 1;
        stakeIdCount = 1;
        _timeForReward = 8 hours;
        powerPlinsGen0 = IERC721Upgradeable(_powerPlinsGen0);
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCard;  
        cat1 = [1,2,3,4,5];
        cat2 = [6,7,8];
        cat3 = [9,10,11,12,13,14,15,16,17,18,19];
        cat4 = [20,21,22,23,24];
        legendryBoost =[27,49,79];
        shinyBoost = [28,50,80];
        range_gen0_1 =  CategoryGen0(1,46,cat1);
        range_gen0_2 =  CategoryGen0(47,76,cat2);
        range_gen0_3 =  CategoryGen0(77,91,cat3);
        range_gen0_4 =  CategoryGen0(92,99, cat4);
        totalTokenStake = 0;
    }

    function updateContractAdress (address _powerPlinsGen0, address _ingredientsERC1155,address _bossCard) public onlyOwner{
        powerPlinsGen0 = IERC721Upgradeable(_powerPlinsGen0);
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCard;
    }

    function setTimeForReward(uint256 timeForReward) public{
        _timeForReward = timeForReward;
    }

    function stake(uint256[] memory tokenIds, bytes memory signature) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, signature);
        require(isSender, "Staking: Invalid sender");
        uint256 amount;
        for (uint256 i = 0; i < tokenIds.length; i += 1) {
            amount += 1;
            powerPlinsGen0.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
        totalTokenStake += tokenIds.length;
        recipeStakers[msg.sender].push(RecipeStaker({
        stakeId:stakeIdCount++,
        tokenIds:tokenIds,
        time: block.timestamp
        }));
        emit Staked(msg.sender, amount, tokenIds);
    }

    function unStack(uint256 _stakeId, bytes memory _signature) public nonReentrant {
        RecipeStaker memory staker = recipeStakers[msg.sender][findIndex(_stakeId)];
        // console.log(staker.tokenIds.length);
        require(staker.tokenIds.length != 0, "unStack: No tokenIds found");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "unStack: Invalid sender");
        uint256[] memory tokenIds =  staker.tokenIds;
        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, staker.time, staker.tokenIds.length);
        require( _numberToClaim == 0,"Rewards left unclaimed!");
        uint256 amount = staker.tokenIds.length;
        for (uint256 i = 0; i < amount; i += 1) {
            powerPlinsGen0.safeTransferFrom(address(this),msg.sender, tokenIds[i]);
        }
        delete tokenIdToRewardsClaimed[msg.sender][_stakeId];
        totalTokenStake -= amount;

        RecipeStaker[] memory stakers = recipeStakers[msg.sender];
        for(uint i=0;i<stakers.length;i++){
            if(stakers[i].stakeId == _stakeId){
                while (i<recipeStakers[msg.sender].length-1) {
                    recipeStakers[msg.sender][i] = recipeStakers[msg.sender][i+1];
                    i++;
                }
                recipeStakers[msg.sender].pop();
            }
        }
        emit Withdrawn(msg.sender, amount, tokenIds);
    }

    function bossCardStake(uint _tokenId, bytes memory _signature) external{
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        require(
            bossCardStakers[msg.sender].tokenId ==0,
            "Boost token already stake"
        );
        require(
            isLegendryBoost(_tokenId) || isShinyBoost(_tokenId),
            "Not valid boost token for stake"
        );
        bossCardStakers[msg.sender] = BossCardStaker({
        tokenId: _tokenId,
        time: block.timestamp
        });
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function bossCardWithdraw(uint _tokenId, bytes memory _signature) external nonReentrant{
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        require(!anyClaimInProgress(), "Claim in progress");
        require(isLegendryBoost(_tokenId) || isShinyBoost(_tokenId),"Not valid boost token for unstake");
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }

    function getBossCountClaim(uint256 stakedTime) public view returns(uint){
        uint bossCount = 0;
        if(bossCardStakers[msg.sender].tokenId !=0){
            uint bossNumber = 2;
            if(isLegendryBoost(bossCardStakers[msg.sender].tokenId)){
                bossNumber = 1;
            }
            bossCount = (((block.timestamp - stakedTime ) / (_timeForReward * 3))) * bossNumber;
        }
        return bossCount;
    }

    function numberOfRewardsToClaim(uint256 _stakeId, uint256 stakeTime , uint tokens) public  view returns (uint) {
        uint256 stakedTime = stakeTime +  (tokenIdToRewardsClaimed[msg.sender][_stakeId] * _timeForReward);

        if(stakedTime == 0)
        {
            return 0;
        }

        uint count = (block.timestamp - stakedTime)  / _timeForReward;
        uint totalCount = count > 0 ? (count* tokens) + getBossCountClaim(stakedTime): 0;
        return totalCount;
    }

    function claimReward(uint256 _stakeId, string memory _genType, bytes memory _signature) public {
        RecipeStaker memory staker = recipeStakers[msg.sender][findIndex(_stakeId)];
        uint256[] memory tokenIds = staker.tokenIds;
        uint256 stakeTime = staker.time;
        //console.log(tokenIds.length);
        //console.log(tokenIds.length == 0);
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "claimReward: Invalid sender");
        require(tokenIds.length != 0, "claimReward: No token Found for claim");
        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, stakeTime,1);
        //console.log("_numberToClaim",_numberToClaim);
        require(_numberToClaim != 0, "claimReward: No claim pending");
        _claimReward(_numberToClaim*tokenIds.length, _stakeId,_genType, _stakeId);

        uint256 lastClaimTime = stakeTime +  (tokenIdToRewardsClaimed[msg.sender][_stakeId] * _timeForReward);
        uint bossClaim = getBossCountClaim(lastClaimTime);
        tokenIdToRewardsClaimed[msg.sender][_stakeId] += (_numberToClaim - bossClaim);
    }

    function _claimReward(uint _numClaim, uint _stakeId,string memory _genType, uint _claimedRewardId) private {
        //console.log(_numClaim);
        for(uint i = 1; i<=_numClaim;i++){
            uint nftId;
            uint index;
            uint number = random(1,100);
            if(number == 100){
                nftId = 25;
            }
            else if(number >= range_gen0_1.from &&  number <= range_gen0_1.to){
                index =   random(0,range_gen0_1.tokenIds.length);
                nftId = index < range_gen0_1.tokenIds.length ? range_gen0_1.tokenIds[index] : range_gen0_1.tokenIds[0];
            }
            else if(number >= range_gen0_2.from &&  number <= range_gen0_2.to){
                index =   random(0,range_gen0_2.tokenIds.length);
                nftId = index < range_gen0_2.tokenIds.length ? range_gen0_2.tokenIds[index] : range_gen0_2.tokenIds[0];
            }
            else if(number >= range_gen0_3.from &&  number <= range_gen0_3.to){
                index =   random(0,range_gen0_3.tokenIds.length);
                nftId = index < range_gen0_3.tokenIds.length ? range_gen0_3.tokenIds[index] : range_gen0_3.tokenIds[0];
            }
            else if(number >= range_gen0_4.from &&  number <= range_gen0_4.to){
                index =   random(0,range_gen0_4.tokenIds.length);
                nftId = index < range_gen0_4.tokenIds.length ? range_gen0_4.tokenIds[index] : range_gen0_4.tokenIds[0];
            }
            //console.log("claim Id",nftId);
            //_mint(msg.sender, nftId, 1,"");
            IIngredientsERC1155(ingredientsERC1155).mint(msg.sender,nftId, 1);
        }
        emit RewardClaimed(msg.sender, _genType, _stakeId, _claimedRewardId, _numClaim);
    }

    function anyClaimInProgress() public  view returns (bool) {
        bool flag = false;
        RecipeStaker[] memory stakers = recipeStakers[msg.sender];
        for(uint256 i =0; i < stakers.length; i++ ){
            uint256 stakeTime =  stakers[i].time;
            uint256 count = numberOfRewardsToClaim(stakers[i].stakeId, stakeTime,stakers[i].tokenIds.length);
            if(count > 0){
                flag = true;
                break;
            }

        }
        return flag;
    }
    
    function printBossCardStakes() public  view returns (uint) {
        return(bossCardStakers[msg.sender].tokenId);
    }

    function printUserClaims() public  view returns (uint256[] memory, uint[] memory) {
        RecipeStaker[] memory stakers = recipeStakers[msg.sender];
        uint256[] memory stakeIds = new uint256[](stakers.length);
        uint256[] memory claims = new uint256[](stakers.length);
        for(uint256 i =0; i < stakers.length; i++ ){
            stakeIds[i] = stakers[i].stakeId;
            uint256 stakeTime =  stakers[i].time;
            claims[i] =  numberOfRewardsToClaim(stakers[i].stakeId, stakeTime,  stakers[i].tokenIds.length);
        }
        return(stakeIds, claims);
    }

    function printUserStakes() public view returns(
        uint256[] memory,
        uint256[] memory,
        uint256[] memory,
        RecipeStaker[] memory
    ) {

        RecipeStaker[] memory stakers = recipeStakers[msg.sender];
        uint256[] memory stakeIds = new uint256[](stakers.length);
        uint256[] memory nftCount = new uint256[](stakers.length);
        uint256[] memory stakeTime = new uint256[](stakers.length);

        for(uint32 i =0; i < stakers.length; i++ ){
            stakeIds[i] = stakers[i].stakeId;
            nftCount[i] =  stakers[i].tokenIds.length;
            stakeTime[i] = stakers[i].time;
        }
        return(stakeIds, nftCount, stakeTime, stakers);
    }

    function  printTotalTokenStake() public view returns(uint256){
        return totalTokenStake;
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256 amount, uint256[] tokenIds);
    event RewardClaimed(
        address indexed user,
        string  getType,
        uint256 indexed _tokenId,
        uint256 _claimedRewardId,
        uint256 _amount
    );
}
