// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "hardhat/console.sol";


interface IGen1ERC1155{
    function mint(address account, uint256 id, uint256 amount) external;
}

interface IPancakeERC1155{
    function mint(address account, uint256 id, uint256 amount) external;
}
interface ISignatureChecker {
    function checkSignature(bytes32 signedHash, bytes memory signature) external returns(bool);
}

contract Event is Initializable, ERC1155HolderUpgradeable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    address public pancakeERC1155;
    address public gen1ERC1155;
    uint256 public shrineRecipeRewardId;
    uint256 public pancakeRewardId;
    address signatureChecker;


    struct RecruitStaker {
        uint tokenId;
        uint256 time;
        bool claimed;
    }
    mapping(address => RecruitStaker) public recruitStaker;
    mapping(uint => uint8) public  recruitPancakeStatus;


    uint256  public _timeForReward;

    /* ========== EVENTS ========== */

    event Staked(address indexed user, uint256 tokenId, uint256 time);
    event Withdrawn(address indexed user, uint256 tokenId);
    event RewardClaimed(
        address indexed user,
        uint _claimedPancakeId,
        uint _claimedShrineId
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _gen1ERC1155, address _pancakeERC1155, address _signatureChecker) external initializer {
        __ReentrancyGuard_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ERC1155Holder_init();
        gen1ERC1155 = _gen1ERC1155;
        pancakeERC1155 = _pancakeERC1155;
        signatureChecker = _signatureChecker;
        shrineRecipeRewardId=510;
        pancakeRewardId=18;
        _timeForReward = 24 hours;
        __Ownable_init();
    }

    function setTimeForReward(uint256 timeForReward) external onlyOwner {
        _timeForReward = timeForReward;
    }


    function stake(uint256 _tokenId) external nonReentrant{
        require(recruitPancakeStatus[_tokenId] == 0, "Event: recruit already claimed");
        recruitPancakeStatus[_tokenId] = 1;
        recruitStaker[msg.sender] = RecruitStaker({
            tokenId: _tokenId,
            time: block.timestamp,
            claimed:false
        });
        emit Staked(msg.sender, _tokenId, block.timestamp);
    }

    function canClaim(uint256 _tokenId) public view returns(bool) {
        require(recruitStaker[msg.sender].tokenId == _tokenId, "Event: invalid recruit token for claim");
        return (recruitStaker[msg.sender].time + _timeForReward) < block.timestamp;
    }

    function updateRecruitStake(address account, bool unStaked, bool _unclaimed) external onlyOwner {
        if(_unclaimed){
         recruitStaker[msg.sender].claimed=false;
        }
        if(unStaked == true){
         delete recruitStaker[account];
        }
    }


    function claimReward(uint256 _tokenId, bytes memory sig) external nonReentrant {
        require(recruitStaker[msg.sender].tokenId == _tokenId, "Event: invalid recruit token for claim");
        require(recruitStaker[msg.sender].claimed != true, "Event: recruit already claimed");
        require(canClaim(_tokenId) == true, "Event: Claim in progress");
        bytes32 message = keccak256(abi.encodePacked(msg.sender,_tokenId));
        bool isSender = ISignatureChecker(signatureChecker).checkSignature(message, sig);
        require(isSender, "Invalid Sender");
        IPancakeERC1155(pancakeERC1155).mint(msg.sender, pancakeRewardId, 1);
        IGen1ERC1155(gen1ERC1155).mint(msg.sender, shrineRecipeRewardId, 1);
        recruitStaker[msg.sender].claimed = true;
        emit RewardClaimed(msg.sender, pancakeRewardId, shrineRecipeRewardId);
    }


    function _authorizeUpgrade(address) internal override onlyOwner {}
}
