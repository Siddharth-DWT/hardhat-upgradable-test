const {CONTRACT_NAME_MAP, approveContract, generateSignature, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const executeBase = true, claimReward=false,successNumber=false, updateRewardTime=true;
const stakeRecipe = false, stakeIngredient = false,  stakeBossCard = false, shrineConst = false;
async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Shrine);
    const DeployedContract = Contract.attach(address.Shrine);

    const PowerPlinsGen0ERC721 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721);
    const PowerPlinsGen0ERC721Deploy = PowerPlinsGen0ERC721.attach(address.PowerPlinsGen0ERC721);

    const BossCardERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
    const BossCardERC1155Deploy = BossCardERC1155.attach(address.BossCardERC1155);


    if(executeBase){
        const timeReward = await DeployedContract.timeForReward()
        console.log("timeReward",timeReward);
        await DeployedContract.setTimeForReward(process.env.TIME_FOR_REWARD)
        const timeReward1 = await DeployedContract.timeForReward()
        console.log("timeReward1",timeReward1);

        await approveContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721,address.PowerPlinsGen0ERC721,address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.BossCardERC1155,address.BossCardERC1155,address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,address.IngredientsERC11155,address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.Shrine, true)
        await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155,address.Gen1ERC1155,address.Shrine, true)

    }
    if(updateRewardTime){
        await DeployedContract.setTimeForReward(process.env.TIME_FOR_REWARD)
        const timeReward1 = await DeployedContract.timeForReward()
        console.log("timeReward1",timeReward1);
    }
    if(stakeRecipe){
        const  printUserRecipeStake = await DeployedContract.printUserRecipeStake()
        console.log("printUserRecipeStake.tokenId",printUserRecipeStake?.tokenId)
        const tokenId = printUserRecipeStake?.tokenId
        if(parseInt(tokenId)){
            const unStakeRecipe = await DeployedContract.unStakeRecipe(tokenId)
            console.log({unStakeRecipe})
        }
        const gen0Tokens = await PowerPlinsGen0ERC721Deploy.walletOfOwner(process.env.OWNER);
        console.log("gen0Tokens---",gen0Tokens);
        const id = String(18 || gen0Tokens[0]);
        const value = String(6);
        const {signature} = generateSignature(process.env.OWNER,id,value);
        console.log({signature})

        //const response = await DeployedContract.stakeRecipe(id,value,signature);
        //console.log("ShrineDeploy stake",response);
    }
    /*var response = await DeployedContract.printUserIngredientStakes()
    console.log("response",response);*/

    if(stakeIngredient){
        try {
            const ids = [1,2,3,4,5], amounts =[1,1,1,1,1]
            await DeployedContract.stakeIngredients(ids,amounts)
            console.log("stakeIngredient done1");
        }catch (e){
            console.log("error in ingredeints stake",e);
        }

    }
    if(successNumber){
        const printUserBossCardStake = await DeployedContract.printUserBossCardStake();
        console.log("printUserBossCardStake stake",printUserBossCardStake);

        console.log("before boss card")
        const getClaimSuccessNumber1 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5],[20,20,20,20,20])
        console.log("getClaimSuccessNumber1 done", getClaimSuccessNumber1);
        const getClaimSuccessNumber2 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5,9],[1,1,1,1,1,1])
        console.log("getClaimSuccessNumber done", getClaimSuccessNumber2);
        const getClaimSuccessNumber3 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5],[2,2,2,2,2])
        console.log("getClaimSuccessNumber3 done", getClaimSuccessNumber3);
    }

    if(stakeBossCard){
        const boostType =
            [{id:14, key:'additive',value:2},
                {id:38, key:'cooldown',value:4},
                { id:59, key:'common',value:2},
                {id:17, key:'uncommon',value:2},
                {id:11, key:'rare',value:3},
                {id:5, key:'epic',value:5},
                {id:57, key:'legendary',value:10}]
        const {id,key,value} = boostType[0]
        const bossTokens = await BossCardERC1155Deploy.getWalletToken();
        console.log("bossTokens---",bossTokens);
        const {message,signature} = generateSignature(process.env.OWNER,id,key,value)
        console.log("signature--->",signature)
        /*try {
            const unstake = await DeployedContract.unStakeBoostCard(id)
            console.log("unstake------",unstake)
        }catch (e){
            console.log("error in unstake",e)
        }*/

        try {
            var response = await DeployedContract.bossCardStake(id,key,value,signature);
            console.log("bosscard stake",response);
        }catch (e){
            console.log("error in boss stake",e)
        }
        var response = await DeployedContract.printUserBossCardStake()
        console.log("bosscard stake",response);
    }

    if(successNumber && stakeBossCard){
        console.log("after boss card")
        const getClaimSuccessNumber1 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5],[20,20,20,20,20])
        console.log("getClaimSuccessNumber1 done", getClaimSuccessNumber1);
        const getClaimSuccessNumber2 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5,9],[1,1,1,1,1,1])
        console.log("getClaimSuccessNumber done", getClaimSuccessNumber2);
        const getClaimSuccessNumber3 = await DeployedContract.getClaimSuccessNumber([1,2,3,4,5],[2,2,2,2,2])
        console.log("getClaimSuccessNumber3 done", getClaimSuccessNumber3);
    }
    if(shrineConst){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.ShrineConst,[])
        const ShrineConstContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ShrineConst);
        const ShrineConstContractChecker = ShrineConstContract.attach(address.ShrineConst);

        const revealNumber= await ShrineConstContractChecker.revealNumber(1,5)
        console.log("revealNumber",revealNumber);
        const revealGen1NftId= await ShrineConstContractChecker.revealGen1NftId()
        console.log("revealGen1NftId",revealGen1NftId);
        const revealPancakeIdNftId = await ShrineConstContractChecker.revealPancakeIdNftId()
        console.log("revealNumber",revealPancakeIdNftId);
    }

    /*const stakeData = await DeployedContract.printUserIngredientStakes()
    console.log("stakeData",stakeData)
    console.log("stakedTime is", new Date((parseInt(stakeData?.stakeTime || 1) * 100)));

    const anyClaimInProgress = await DeployedContract.anyClaimInProgress()
    console.log("anyClaimInProgress done", anyClaimInProgress);*/

    if(claimReward && anyClaimInProgress){
        /*const stakeData = await DeployedContract.printUserIngredientStakes()
        console.log("stakeData done", stakeData);
        console.log("stakeTime done", stakeData?.stakeTime);

        const anyClaimInProgress = await DeployedContract.anyClaimInProgress()
        console.log("anyClaimInProgress done", anyClaimInProgress);*/

        try {
            const {message,signature} = generateSignature(process.env.OWNER)
            const claim = await DeployedContract.claimRewards(signature)
            console.log("claim done", claim);
        }catch (e){
            console.log("error in claim",e);
        }

    }



}
main()
