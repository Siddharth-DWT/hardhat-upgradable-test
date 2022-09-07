// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./SignatureChecker.sol";
import "hardhat/console.sol";

interface IIngredientERC1155{
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function burn(address account, uint256 id, uint256 value) external;
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

contract ShrineStake is Initializable, ERC721HolderUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable, SignatureChecker {
    uint nonce;
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

    struct LastClaimed{
        uint[] tokenIds;
        uint number;
        uint randomId;
        bool isFail;
    }

    mapping(address => IngredientStaker) private IngredientStakers;
    mapping(address => LastClaimed) private userLastClaim;

    struct IngredientChance{
        uint chance;
        uint[] ids;
    }

    //ingredient types
    uint[] common;
    uint[] uncommon;
    uint[] rare;
    uint[] epic;
    uint[] legendary;

    // IngredientChance chance1;
    // IngredientChance chance2;
    // IngredientChance chance3;
    // IngredientChance chance4;
    // IngredientChance chance5;

    //boss card ids
    uint[] bossCard;

    //boost category
    // uint[] additiveBoost;
    // uint[] commonIngBoost;
    // uint[] uncommonIngBoost;
    // uint[] rareIngBoost;
    // uint[] epicIngBoost;
    // uint[] legendaryIngBoost;
    uint[] cooldownBoost;

    //bosscard info
    struct BossCardStakers{
        uint tokenId;
        string traitType;
        uint value;
    }
    mapping(address => BossCardStakers) private bossCardStakers;

    function setTimeForReward(uint256 _time) public {
        _timeForReward = _time;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function random(uint from, uint to) internal returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % to;
        randomnumber = from + randomnumber ;
        nonce++;
        return randomnumber;
    }

    function isCommon(uint tokenId) internal view  returns (bool){
        bool found= false;
        for (uint i=0; i<common.length; i++) {
            if(common[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isUncommon(uint tokenId) internal view returns (bool){
        bool found= false;
        for (uint i=0; i<uncommon.length; i++) {
            if(uncommon[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isRare(uint tokenId) internal view  returns (bool){
        bool found= false;
        for (uint i=0; i<rare.length; i++) {
            if(rare[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
    }

    function isEpic(uint tokenId) internal view returns (bool){
        bool found= false;
        for (uint i=0; i<epic.length; i++) {
            if(epic[i]==tokenId){
                found=true;
                break;
            }
        }
        return found;
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

    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }

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
        common = [1,2,3,4,5];
        uncommon = [6,7,8];
        rare = [9,10,11,12,13,14,15,16,17,18,19];
        epic = [20,21,22,23,24];
        legendary = [25];
        // chance1 =  IngredientChance(2,common);
        // chance2 =  IngredientChance(5,uncommon);
        // chance3 =  IngredientChance(12,rare);
        // chance4 =  IngredientChance(30,epic);
        // chance5 =  IngredientChance(120,legendary);
        bossCard = [13, 29, 43, 14, 30, 44, 59, 65, 75, 85, 60, 66, 76, 86, 17, 25, 87, 18, 26, 88,
        11, 41, 105, 12, 42, 106, 5, 21, 71, 93, 6, 22, 72, 94, 57, 81, 91, 58, 82, 92,
        37, 63, 97, 38, 94, 98];
        // additiveBoost =[13,29,43,14,30,44];
        // commonIngBoost = [59,65,75,85,60,66,76,86];
        // uncommonIngBoost = [17,25,87,18,26,88];
        // rareIngBoost = [11,41,105,12,42,106];
        // epicIngBoost = [5,21,71,93,6,22,72,94];
        // legendaryIngBoost = [57,81,91,58,82,92];
        cooldownBoost = [37,63,97,38,94,98];
    }

    function updateContractAdress (address _powerPlinsGen0, address _ingredientsERC1155, address _bossCardERC1155, address _gen1ERC1155, address _pancakeERC1155) public onlyOwner{
        powerPlinsGen0 = IERC721Upgradeable(_powerPlinsGen0);
        ingredientsERC1155 = _ingredientsERC1155;
        bossCardERC1155 = _bossCardERC1155;
        gen1ERC1155 = _gen1ERC1155;
        pancakeERC1155 = _pancakeERC1155;
    }

    function stakeRecipeERC721(uint _tokenId, uint _boostValue, bytes memory _signature) external nonReentrant {
        require(_tokenId >= 0, "Staking: No tokenIds provided");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "Staking: Invalid sender");
        powerPlinsGen0.safeTransferFrom(msg.sender, address(this), _tokenId);
        recipeStake[msg.sender].tokenId = _tokenId;
        recipeStake[msg.sender].boostValue = _boostValue;
        recipeStake[msg.sender].time = block.timestamp;
        emit Staked(msg.sender, _tokenId);
    }

    function unStakeRecipeERC721(uint _tokenId, bytes memory _signature) public nonReentrant {
        require(_tokenId >= 0, "unStack: No tokenId found");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "unStack: Invalid sender");
        require(recipeStake[msg.sender].tokenId >= 0, "unStack: No tokenId found");
        require(!anyClaimInProgress(),"Reward in progress");
        powerPlinsGen0.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete recipeStake[msg.sender].tokenId;
        delete recipeStake[msg.sender].boostValue;
        delete recipeStake[msg.sender].time;
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

    function bossCardStake(uint _tokenId, string memory _traitType, uint _value, bytes memory _signature) external{
        bool exist;
        for(uint i=0; i< bossCard.length; i++){
            if(bossCard[i] == _tokenId){
                exist = true;
                break;
            }
        }
        require(exist, "can't stake this token");
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
        require(
            !anyClaimInProgress(),
            "Claim in progress"
        );
        bool exist;
        for(uint i=0; i< bossCard.length; i++){
            if(bossCard[i] == _tokenId){
                exist = true;
                break;
            }
        }
        require(exist, "Not valid boost token for unstake");
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
        console.log("step4");
        string memory boostType =  bossCardStakers[msg.sender].traitType;
        if( bossCardStakers[msg.sender].tokenId == 0  || !compareStrings(boostType,_mulName))
        {
            return _mulValue;
        }
        console.log("step5");
        uint value = bossCardStakers[msg.sender].value;
        console.log("step6");
        return (_mulValue + value);
    }

    function prepareNumber( uint[] memory ids,uint[] memory amounts ) internal view returns(uint){
        uint commonIng =0;
        uint uncommonIng= 0;
        uint rareIng = 0;
        uint epicIng =0;
        uint legendaryIng = 0;

        console.log("step1");

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
        console.log("step2");
        number = (number * 100) + (number * ((commonIng*getBoostValue(2,"common")) + (uncommonIng*getBoostValue(5,"uncommon")) + (rareIng*getBoostValue(12,"rare")) + (epicIng*getBoostValue(30,"epic")) + (legendaryIng*getBoostValue(120,"legendary"))));
        console.log("step3");
        return number;
    }

    function getClaimSuccessNumber() internal view returns(uint){
        return prepareNumber(IngredientStakers[msg.sender].tokenIds, IngredientStakers[msg.sender].amounts);
    }

    //Claim rewards for IngredientsERC1155
    function claimRewards(bytes memory _signature) public{
        uint256[] memory tokenIds = IngredientStakers[msg.sender].tokenIds;
        uint256[] memory amounts = IngredientStakers[msg.sender].amounts;
        uint256 stakeTime = IngredientStakers[msg.sender].stakeTime;

        require(tokenIds.length != 0, "claimReward: No claimReward found");
        bytes32 message = keccak256(abi.encodePacked(msg.sender));
        bool isSender = checkSignature(message, _signature);
        require(isSender, "claimReward: Invalid sender");
        require(canAvailableClaim(stakeTime), "claimReward: stake not available for claim");

        uint successNo = getClaimSuccessNumber();
        uint genrateNumber = random(1, 10000);
        bool isChanceFail = genrateNumber > successNo;
        uint pancakeClaimId = 19;
        uint gen1ClaimId = 0;

        if(isChanceFail){
            IPancakeERC1155(pancakeERC1155).mint(msg.sender, pancakeClaimId, 1);
        }else{
            uint gen1MintId = random(1,500);
            uint pancakeMintId = random(1,18);
            gen1ClaimId = gen1MintId;
            pancakeClaimId = pancakeMintId;
            IGen1ERC1155(gen1ERC1155).mint(msg.sender, gen1MintId, 1);
            IPancakeERC1155(pancakeERC1155).mint(msg.sender, pancakeMintId, 1);
        }

        for(uint i=0; i < tokenIds.length; i++){
            IIngredientERC1155(ingredientsERC1155).burn(address(this), tokenIds[i], amounts[i]);
            delete IngredientStakers[msg.sender].tokenIds[i];
            delete IngredientStakers[msg.sender].amounts[i];
        }

        delete IngredientStakers[msg.sender].stakeTime;
        userLastClaim[msg.sender].randomId = genrateNumber;
        userLastClaim[msg.sender].tokenIds = [pancakeClaimId, gen1ClaimId];
        userLastClaim[msg.sender].number = successNo;
        userLastClaim[msg.sender].isFail = isChanceFail;
        emit RewardClaimed(msg.sender, genrateNumber, successNo, pancakeClaimId, gen1ClaimId);
    }


    function getTimeForReward() public view returns(uint256){
        uint256 rewardTime = _timeForReward;
        if(bossCardStakers[msg.sender].tokenId == 0){
            return rewardTime;
        }
        else if(iscooldownBoost(bossCardStakers[msg.sender].tokenId)){
            uint time = bossCardStakers[msg.sender].value;
            rewardTime = rewardTime - time;
        }
        return rewardTime;
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

    function printUserLastClaim() public view returns(LastClaimed memory) {
        return userLastClaim[msg.sender];
    }

    function genrateRandomNUmberValue() public  returns(uint){
        uint val  = random(1, 1000);
        console.log(val);
        return random(1, 1000);
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