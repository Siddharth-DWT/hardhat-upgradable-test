const {CONTRACT_NAME_MAP, approveContract, generateSignature} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const executeBase = false, claimReward=true,successNumber=false;
const stakeIngredient = false, stakeRecipe = false, stakeBossCard = false;
async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Shrine);
    const DeployedContract = Contract.attach(address.Shrine);

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
    if(stakeRecipe){
        const PowerPlinsGen0ERC721 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721);
        const PowerPlinsGen0ERC721Deploy = PowerPlinsGen0ERC721.attach(address.PowerPlinsGen0ERC721);

        const gen0Tokens = await PowerPlinsGen0ERC721Deploy.walletOfOwner(process.env.OWNER);
        console.log("gen0Tokens---",gen0Tokens);
        var response = await DeployedContract.stakeRecipe(gen0Tokens[0], 11);
        console.log("ShrineDeploy stake",response);

    }

    /*var response = await DeployedContract.printUserIngredientStakes()
    console.log("response",response);*/

    if(stakeIngredient){
        try {
            var ids = [1,2,3,4,5], amounts =[1,1,1,1,1]
            await DeployedContract.stakeIngredients(ids,amounts)
            console.log("stakeIngredient done1");
        }catch (e){
            console.log("error in ingredeints stake",e);
        }

    }

    if(stakeBossCard){
        const BossCardERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
        const BossCardERC1155Deploy = BossCardERC1155.attach(address.BossCardERC1155);
        const boostType =
            [{id:37, key:'cooldown',value:2},{id:38, key:'cooldown',value:4},
            {id:63, key:'cooldown',value:2},{id:64, key:'cooldown',value:4},
            {id:97, key:'cooldown',value:2},{id:98, key:'cooldown',value:4}]
        const {id,key,value} = boostType[0]
        //const bossTokens = await BossCardERC1155Deploy.getWalletToken();
        //console.log("bossTokens---",bossTokens);
        const {message,signature} = generateSignature(process.env.OWNER,id,key,value)
        console.log("signature--->",signature)
        try {
            const unstake = await DeployedContract.unStakeBoostCard(id)
            console.log("unstake------",unstake)
        }catch (e){
            console.log("error in unstake",e)
        }

        try {
            var response = await DeployedContract.bossCardStake(id,key,value,signature);
            console.log("bosscard stake",response);
        }catch (e){
            console.log("error in boss stake",e)
        }
        var response = await DeployedContract.printUserBossCardStake()
        console.log("bosscard stake",response);
    }
    const stakeData = await DeployedContract.printUserIngredientStakes()
    console.log("stakeData done", stakeData);
    console.log("stakeTime done", stakeData?.stakeTime);

    const anyClaimInProgress = await DeployedContract.anyClaimInProgress()
    console.log("anyClaimInProgress done", anyClaimInProgress);
    if(successNumber){
        try {
            const successNumber = await DeployedContract.getClaimSuccessNumber()
            console.log("successNumber done", successNumber);
        }catch (e){
            console.log("error in successNumber",e);
        }

    }

    if(claimReward){
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
