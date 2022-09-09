// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./CommonConst.sol";
import "hardhat/console.sol";

interface IGen1ERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

interface IIngredientsERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function mint(address to, uint256 id, uint256 value) external;
}

contract ErrandGen1 is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, PausableUpgradeable, UUPSUpgradeable, CommonConst {
    uint256 stakeIdCount;
    uint256  _timeForReward;
    address private powerPlinsGen1;
    address private ingredientsERC1155;

    struct Gen1Staker {
        uint256 stakeId;
        uint[] tokenIds;
        uint256  time;
    }

    mapping(address => Gen1Staker[]) gen1Stakers;
    mapping(address => mapping(uint256 => uint256))  tokenIdToRewardsClaimed;


    function findIndex(uint value) internal view returns(uint) {
        uint i = 0;
        Gen1Staker[] memory stakers = gen1Stakers[msg.sender];
        while (stakers[i].stakeId != value) {
            i++;
        }
        return i;
    }

    function initialize(address _powerPlinsGen1, address _ingredientsERC1155) external initializer {
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __UUPSUpgradeable_init();
        powerPlinsGen1 = _powerPlinsGen1;
        ingredientsERC1155 = _ingredientsERC1155;
        __Common_initGen1();
        stakeIdCount = 1;
        _timeForReward = 24 hours;
    }

    function setTimeForReward(uint256 timeForReward) public{
        _timeForReward = timeForReward;
    }

    function stake(uint256[] memory tokenIds) external nonReentrant whenNotPaused{
        require(tokenIds.length != 0, "Staking: No tokenIds provided");
        uint256 amount;
        for (uint256 i = 0; i < tokenIds.length; i += 1) {
            amount += 1;
            IGen1ERC1155(powerPlinsGen1).safeTransferFrom(msg.sender, address(this), tokenIds[i],1,'');

        }
        gen1Stakers[msg.sender].push(Gen1Staker({
            stakeId:stakeIdCount++,
            tokenIds:tokenIds,
            time: block.timestamp
        }));
        emit Staked(msg.sender, amount, tokenIds);
    }

    function unStack(uint256 _stakeId) public nonReentrant {
        Gen1Staker memory staker = gen1Stakers[msg.sender][findIndex(_stakeId)];
        require(staker.tokenIds.length != 0, "unStack: No tokenIds found");

        uint256[] memory tokenIds =  staker.tokenIds;
        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, staker.time, staker.tokenIds.length);
        require( _numberToClaim == 0,"Rewards left unclaimed!");

        uint256 amount = staker.tokenIds.length;
        for (uint256 i = 0; i < amount; i += 1) {
            IGen1ERC1155(powerPlinsGen1).safeTransferFrom(address(this),msg.sender, tokenIds[i], 1, '');
        }
        delete tokenIdToRewardsClaimed[msg.sender][_stakeId];
        Gen1Staker[] memory stakers = gen1Stakers[msg.sender];
        for(uint i=0;i<stakers.length;i++){
            if(stakers[i].stakeId == _stakeId){
                while (i<gen1Stakers[msg.sender].length-1) {
                    gen1Stakers[msg.sender][i] = gen1Stakers[msg.sender][i+1];
                    i++;
                }
                gen1Stakers[msg.sender].pop();
            }
        }
        emit Withdrawn(msg.sender, amount, tokenIds);
    }



    function numberOfRewardsToClaim(uint256 _stakeId, uint256 stakeTime , uint tokens) public  view returns (uint) {
        uint256 stakedTime = stakeTime +  (tokenIdToRewardsClaimed[msg.sender][_stakeId] * _timeForReward);
        if(stakedTime == 0) {
            return 0;
        }

        uint count = (block.timestamp - stakedTime)  / _timeForReward;
        uint totalCount = count > 0 ? (count* tokens) : 0;
        return totalCount;
    }

    function claimReward(uint256 _stakeId) public {
        Gen1Staker memory staker = gen1Stakers[msg.sender][findIndex(_stakeId)];
        uint256[] memory tokenIds = staker.tokenIds;
        uint256 stakeTime = staker.time;
        require(tokenIds.length != 0, "claimReward: No token Found for claim");
        uint _numberToClaim =  numberOfRewardsToClaim(_stakeId, stakeTime,1);
        require(_numberToClaim != 0, "claimReward: No claim pending");
        _claimReward(_numberToClaim*tokenIds.length, _stakeId);
        tokenIdToRewardsClaimed[msg.sender][_stakeId] += _numberToClaim;
    }

    function _claimReward(uint _numClaim, uint _stakeId) private {
        uint[] memory ingredientNftIds = new uint[](_numClaim);
        for(uint i = 1; i<=_numClaim;i++){
            uint nftId = getRandomIngredientId();
            ingredientNftIds[i-1] = nftId;
            console.log("claim Id -1",nftId);
            IIngredientsERC1155(ingredientsERC1155).mint(msg.sender,nftId, 1);
        }
        emit RewardClaimed(msg.sender,  _stakeId, ingredientNftIds);
    }

    function anyClaimInProgress() public  view returns (bool) {
        bool flag = false;
        Gen1Staker[] memory stakers = gen1Stakers[msg.sender];
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

    function getTimeForReward() public view returns(uint256){
        return _timeForReward;
    }

    function printUserGen1Claims() public  view returns (uint256[] memory, uint[] memory) {
        Gen1Staker[] memory stakers = gen1Stakers[msg.sender];
        uint256[] memory stakeIds = new uint256[](stakers.length);
        uint256[] memory claims = new uint256[](stakers.length);
        for(uint256 i =0; i < stakers.length; i++ ){
            stakeIds[i] = stakers[i].stakeId;
            uint256 stakeTime =  stakers[i].time;
            claims[i] =  numberOfRewardsToClaim(stakers[i].stakeId, stakeTime,  stakers[i].tokenIds.length);
        }
        return(stakeIds, claims);
    }

    function printUserGen1Stakes() public view returns(Gen1Staker[] memory){
        return gen1Stakers[msg.sender];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 amount, uint256[] tokenIds);
    event Withdrawn(address indexed user, uint256 amount, uint256[] tokenIds);
    event RewardClaimed(
        address indexed user,
        uint256 _claimedRewardId,
        uint[] ingredientNftIds
    );
}
