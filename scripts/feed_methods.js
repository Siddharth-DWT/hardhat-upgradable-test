const {CONTRACT_NAME_MAP, approveContract, generateSignature,sumOf} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const {parse} = require("dotenv");
const executeBase = false;
const stakePancake = false, stakeBossCard=false,revealReward=true;
async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Feed);
    const DeployedContract = Contract.attach(address.Feed);

    const BossCardERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
    const DeployedBossContract = BossCardERC1155.attach(address.BossCardERC1155);

    const PancakeNftERC11155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PancakeNftERC11155);
    const DeployedPancakeContract = PancakeNftERC11155.attach(address.PancakeNftERC11155);


    const IngredientERC11155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
    const DeployedIngredientContract = IngredientERC11155.attach(address.IngredientsERC11155);

    if(executeBase){
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.Feed)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,address.IngredientsERC11155,address.Feed, true)
        await approveContract(CONTRACT_NAME_MAP.BossCardERC1155,address.BossCardERC1155,address.Feed, true)
    }

    if(stakePancake){
        const input1 = [1],input2 = [1], input3= 1140;
        const {signature,message} = generateSignature(process.env.OWNER,input3);
        console.log({signature})
        console.log({message})
        await DeployedContract.stake(input1,input2,input3,signature)
        console.log("pancake stake done1");
    }


    if(revealReward){
        var ingredientTokens = await DeployedIngredientContract.getWalletToken()
        var count = 0;
        ingredientTokens.forEach((item)=>{
            count = count + parseInt(item)
        })
        console.log("count before",count)
        let input1 = [10,12,13,14,15],input2 = [9,10],input3 = [1,1];
        console.log("sumOf(input1),sumOf(input2),sumOf(input3)",sumOf(input1),sumOf(input2),sumOf(input3))
        const {signature,message} = generateSignature(process.env.OWNER,sumOf(input1),sumOf(input2),sumOf(input3));
        console.log({signature})
        input1 = [10,12,13,14,15]
        const response = await DeployedContract.reveal(input1,input2,input3,signature)
        console.log("reveal done",response);
        var ingredientTokens = await DeployedIngredientContract.getWalletToken()
        //console.log("ingredientTokens",ingredientTokens)
        var count = 0;
        ingredientTokens.forEach((item)=>{
            count = count + parseInt(item)
        })
        console.log("count after",count)

    }
    if(stakeBossCard){
        //const input = [[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1],[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1]]
        await DeployedContract.stake(1)
        console.log("stake done1");
        const printUserFeeds = await DeployedContract.printUserFeeds()
        console.log("printUserFeeds",printUserFeeds);
        const printUserBossCardStake = await DeployedContract.printUserBossCardStake()
        console.log("printUserBossCardStake",printUserBossCardStake);

    }


}
main()
