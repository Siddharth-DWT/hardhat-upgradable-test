// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SignatureChecker.sol";
import "./CommonConst.sol";
//import "hardhat/console.sol";

interface IIngredientERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) external;
}

interface IGen1ERC1155{
    function mint(address account, uint256 id, uint256 amount) external;
}

interface IPancakeERC1155{
    function mint(address account, uint256 id, uint256 amount) external;
}

interface IBossCardERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
}

contract ShrineStake is Initializable, ERC721HolderUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable, CommonConst,SignatureChecker {
    uint ceilSuccessNo;
    uint256 public _timeForReward;
    uint StakeId;

    // for stake
    IERC721Upgradeable private powerPlinsGen0;
    address ingredientsERC1155;
    address bossCardERC1155;

    //for reward
    address gen1ERC1155;
    address pancakeERC1155;

    //recipe info
    struct RecipeStake{
        uint tokenId;
        uint time;
        uint boostValue;
    }
    mapping(address => RecipeStake) private recipeStake;

    //ingredients info
    struct IngredientStaker{
        uint[] tokenIds;
        uint[] amounts;
        uint stakeTime;
    }
    mapping(address => IngredientStaker) private IngredientStakers;


    uint[] bossCard;
    uint[] cooldownBoost;

    //bosscard info
    struct BossCardStakers{
        uint tokenId;
        string traitType;
        uint value;
    }
    mapping(address => BossCardStakers) private bossCardStakers;
    function initialize(address _powerPlinsGen0, address _ingredientsERC1155, address _bossCardERC1155, address _gen1ERC1155, address _pancakeERC1155) external initializer {
        __ERC721Holder_init();
        __Ownable_init();
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __SigChecker_init();
        nonce = 1;
        ceilSuccessNo = 10000;
        _timeForReward = 2 hours;
        StakeId = 1;
        powerPlinsGen0 = IERC721Upgradeable(_powerPlinsGen0);
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
        gen1ERC1155 = _gen1ERC1155;
        pancakeERC1155 = _pancakeERC1155;
        bossCard = [13, 29, 43, 14, 30, 44, 59, 65, 75, 85, 60, 66, 76, 86, 17, 25, 87, 18, 26, 88,
        11, 41, 105, 12, 42, 106, 5, 21, 71, 93, 6, 22, 72, 94, 57, 81, 91, 58, 82, 92,
        37, 63, 97, 38, 94, 98];
        cooldownBoost = [37,63,97,38,94,98];
    }

    function setTimeForReward(uint256 _time) public {
        _timeForReward = _time;
    }

    function iscooldownBoost(uint tokenId) internal view  returns (bool){
        bool found= false;
        for (uint i=0; i < cooldownBoost.length; i++) {
            if(cooldownBoost[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }


    function stakeRecipeERC721(uint _tokenId, uint _boostValue) external nonReentrant {
        require(_tokenId >= 0, "Staking: No tokenIds provided");

        powerPlinsGen0.safeTransferFrom(msg.sender, address(this), _tokenId);
        recipeStake[msg.sender].tokenId = _tokenId;
        recipeStake[msg.sender].boostValue = _boostValue;
        recipeStake[msg.sender].time = block.timestamp;
        emit Staked(msg.sender, _tokenId);
    }

    function unStakeRecipeERC721(uint _tokenId) public nonReentrant {
        require(_tokenId >= 0, "unStack: No tokenId found");
        require(recipeStake[msg.sender].tokenId >= 0, "unStack: No tokenId found");
        require(!anyClaimInProgress(),"Reward in progress");

        powerPlinsGen0.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete recipeStake[msg.sender];
        emit UnStaked(msg.sender, _tokenId);
    }

    function stakeIngredientsERC1155(uint[] memory _tokenIds, uint[] memory _amounts, bytes memory _signature) external nonReentrant {
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "stake: Invalid sender");
        require(recipeStake[msg.sender].tokenId > 0, "stake: First stake 721 Nft!");
        require(_tokenIds.length == _amounts.length, "stake: length mismatch");
        uint countAmount = 0;
        for(uint i=0; i < _amounts.length; i++){
            countAmount = countAmount + _amounts[i];
        }
        require(countAmount >= 5 && countAmount <= 100, "stake: minimum 5 and maximum 100 can stake");

        for(uint i=0; i < _tokenIds.length; i++){
            IIngredientERC1155(ingredientsERC1155).safeTransferFrom(msg.sender, address(this), _tokenIds[i], _amounts[i],'');
        }
        IngredientStakers[msg.sender].tokenIds = _tokenIds;
        IngredientStakers[msg.sender].amounts = _amounts;
        IngredientStakers[msg.sender].stakeTime = block.timestamp;
        //IngredientStakers[msg.sender][StakeId].stakeId = StakeId;

        StakeId++;
    }

    function bossCardStake(uint _tokenId, string memory _traitType, uint _value, bytes calldata _signature) external{
        bool exist;
        for(uint i=0; i< bossCard.length; i++){
            if(bossCard[i] == _tokenId){
                exist = true;
                break;
            }
        }
        require(exist, "can't stake this token");
        bytes32 message = keccak256(abi.encodePacked(_tokenId,_traitType,_value,msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Invalid sender");
        bossCardStakers[msg.sender] = BossCardStakers({
            tokenId: _tokenId,
            traitType: _traitType,
            value: _value
        });
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(msg.sender, address(this), _tokenId, 1,'');
    }

    function unStakeBoostCard(uint _tokenId) external{
        require(
            !anyClaimInProgress(),
            "Claim in progress"
        );
        IBossCardERC1155(bossCardERC1155).safeTransferFrom(address(this), msg.sender,_tokenId, 1,'');
        delete bossCardStakers[msg.sender];
    }

    function canAvailableClaim(uint256 _stakeTime) public view returns (bool) {
        if(_stakeTime == 0){
            return false;
        }
        uint256 stakedTime = _stakeTime + getTimeForReward();
        return block.timestamp > stakedTime;
    }

    function anyClaimInProgress() public view returns(bool){
        bool flag = false;
        uint256[] memory stakeIds = IngredientStakers[msg.sender].tokenIds;
        uint staketime = IngredientStakers[msg.sender].stakeTime;
        for(uint256 i=0; i < stakeIds.length; i++ ){
            if(canAvailableClaim(staketime)){
                flag = true;
                break;
            }
        }
        return flag;
    }

    function getBoostValue(uint _mulValue, string memory _mulName) internal view returns(uint){
        string memory boostType =  bossCardStakers[msg.sender].traitType;
        if( bossCardStakers[msg.sender].tokenId == 0  || !compareStrings(boostType,_mulName)){
            return _mulValue;
        }
        //console.log("step5");
        uint value = bossCardStakers[msg.sender].value;
        //console.log("step6");
        return (_mulValue + value);
    }

    function prepareNumber( uint[] memory ids,uint[] memory amounts ) internal view returns(uint){
        uint commonIng =0;
        uint uncommonIng= 0;
        uint rareIng = 0;
        uint epicIng =0;
        uint legendaryIng = 0;
        //console.log("step1");
        for(uint i=0;i<ids.length;i++){
            if(isCommon(ids[i])){
                commonIng += 1*amounts[i];
            }
            else if(isUncommon(ids[i])){
                uncommonIng += 1*amounts[i];
            }
            else if(isRare(ids[i])){
                rareIng += 1*amounts[i];
            }
            else if(isEpic(ids[i])){
                epicIng += 1*amounts[i];
            }
            else if(ids[i] == legendary[0]){
                legendaryIng += 1*amounts[i];
            }
        }
        uint number = 1;
        if(recipeStake[msg.sender].tokenId > 0){
            number += recipeStake[msg.sender].boostValue;
        }
        string memory boostType =  bossCardStakers[msg.sender].traitType;
        if( bossCardStakers[msg.sender].tokenId != 0  && compareStrings(boostType,"additive")){
            number += bossCardStakers[msg.sender].value;
        }
        //console.log("step2");
        number = (number * 100) + (number * ((commonIng*getBoostValue(2,"common")) + (uncommonIng*getBoostValue(5,"uncommon")) + (rareIng*getBoostValue(12,"rare")) + (epicIng*getBoostValue(30,"epic")) + (legendaryIng*getBoostValue(120,"legendary"))));
        //console.log("step3");
        return number;
    }

    function getClaimSuccessNumber() internal view returns(uint){
        return prepareNumber(IngredientStakers[msg.sender].tokenIds, IngredientStakers[msg.sender].amounts);
    }

    //Claim rewards for IngredientsERC1155
    function claimRewards(bytes calldata _signature) public{
        uint256[] memory tokenIds = IngredientStakers[msg.sender].tokenIds;
        uint256[] memory amounts = IngredientStakers[msg.sender].amounts;
        uint256 stakeTime = IngredientStakers[msg.sender].stakeTime;

        require(tokenIds.length != 0, "claimReward: No claimReward found");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "claimReward: Invalid sender");
        require(canAvailableClaim(stakeTime), "claimReward: stake not available for claim");

        uint successNo = getClaimSuccessNumber();
        uint genrateNumber = random(1, ceilSuccessNo);
        bool isChanceFail = genrateNumber > successNo;
        uint pancakeClaimId = 19;
        uint gen1ClaimId = 0;

        if(isChanceFail){
            IPancakeERC1155(pancakeERC1155).mint(msg.sender, pancakeClaimId, 1);
        }else{
            uint gen1MintId = random(1,510);
            uint pancakeMintId = random(1,18);
            gen1ClaimId = gen1MintId;
            pancakeClaimId = pancakeMintId;
            IGen1ERC1155(gen1ERC1155).mint(msg.sender, gen1MintId, 1);
            IPancakeERC1155(pancakeERC1155).mint(msg.sender, pancakeMintId, 1);
        }

        IIngredientERC1155(ingredientsERC1155).burnBatch(address(this), tokenIds, amounts);
        delete IngredientStakers[msg.sender];
        emit RewardClaimed(msg.sender, genrateNumber, successNo, pancakeClaimId, gen1ClaimId);
    }

    function getTimeForReward() public view returns(uint256){
        if(iscooldownBoost(bossCardStakers[msg.sender].tokenId)){
            uint time = bossCardStakers[msg.sender].value;
            return _timeForReward - time;
        }
        return _timeForReward;
    }

    function getClaimSuccessNumber(uint[] memory ids,uint[] memory amounts) public view returns(uint){
        return prepareNumber(ids, amounts);
    }

    function printUserIngredientStakes() public view returns(IngredientStaker memory) {
        return IngredientStakers[msg.sender];
    }

    function printUserRecipeStake() public view returns(RecipeStake memory) {
        return recipeStake[msg.sender];
    }

    function printUserBossCardStake() public view returns(BossCardStakers memory) {
        return bossCardStakers[msg.sender];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    event Staked(address indexed user, uint256 tokenId);
    event UnStaked(address indexed user, uint256 tokenId);
    event RewardClaimed(
        address indexed user,
        uint randomId,
        uint successNumber,
        uint pancakeClaimId,
        uint gen1ClaimId
    );
}