const {CONTRACT_NAME_MAP, approveContract, generateSignature,generateFeedRevealSignature} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const {parse} = require("dotenv");
const executeBase = false;
const stakePancake = false, stakeBossCard=false,revealReward=true;
async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Feed);
    const DeployedContract = Contract.attach(address.Feed);

    if(executeBase){
        //const timeReward = await DeployedContract.timeForReward()
        //console.log("timeReward",timeReward);
       //await DeployedContract.setTimeForReward(process.env.TIME_FOR_REWARD)
        //const timeReward1 = await DeployedContract.timeForReward()
        //console.log("timeReward1",timeReward1);
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.Feed)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,address.IngredientsERC11155,address.Cook, true)
        await approveContract(CONTRACT_NAME_MAP.BossCardERC1155,address.BossCardERC1155,address.Cook, true)

    }

    if(stakePancake){
        //const input1 = [1],input2 = [1], input3= 740;
        const {signature,message} = generateSignature(process.env.OWNER,[1,2,3]);
        console.log({signature})
        console.log({message})

        //await DeployedContract.stake(input1,input2,input3,signature)
        console.log("stake done1");

    }

    if(revealReward){
        //const input1 = [1],input2 = [1], input3= 740;
        const {signature,message} = generateFeedRevealSignature(process.env.OWNER,[1,2,2,2,2],[9,10],[1,1]);
        console.log({signature})
        console.log({message})
        const res = await DeployedContract.getMessageHash([1,2,2,2,2],[9,10],[1,1]);
        console.log("hash is",res);
        //const response = await DeployedContract.reveal([1,0,0,0,0],[9,10],[1,1],signature)
        //console.log("stake done1",response);

    }


    if(stakeBossCard){
        const input = [[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1],[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1]]
        await DeployedContract.stake(input)
        console.log("stake done1");
        await DeployedContract.stake(input)
        console.log("stake done2");
    }



   /* const printUserFeeds = await DeployedContract.printUserFeeds()
    console.log("printUserFeeds",printUserFeeds);
    const printUserBossCardStake = await DeployedContract.printUserBossCardStake()
    console.log("printUserFeeds",printUserBossCardStake);*/

}
main()
