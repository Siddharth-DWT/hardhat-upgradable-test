const {CONTRACT_NAME_MAP, approveContract, generateSignature, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const executeBase = true, printTime=true;
async function main(){
    console.log("step1")
    const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen0);
    console.log("step11")
    const ErrandGen0Deploy = ErrandGen0Contract.attach(address.ErrandGen0);
    console.log("step2")
    const ErrandGen1Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen1);
    const ErrandGen1Deploy = ErrandGen1Contract.attach(address.ErrandGen1);
    console.log("step21")
    const ErrandBossCardStakeContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandBossCardStake);
    const DeployedErrandBossCardStake = ErrandBossCardStakeContract.attach(address.ErrandBossCardStake);
    console.log("step23")
    const ContractCook = await ethers.getContractFactory(CONTRACT_NAME_MAP.Cook);
    const DeployedContractCook = ContractCook.attach(address.Cook);
    console.log("step24")
    const ContractShrine = await ethers.getContractFactory(CONTRACT_NAME_MAP.Shrine);
    const DeployedContractShrine = ContractShrine.attach(address.Shrine);

    console.log("step2")

    if(executeBase) {
        //Errand
        await approveContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721, address.PowerPlinsGen0ERC721, address.ErrandGen0)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.ErrandGen0, true)
        await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155, address.Gen1ERC1155, address.ErrandGen1)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.ErrandGen1, true)

        await ErrandGen0Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)
        await ErrandGen1Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)

        //Cook
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.Cook)
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155, address.PancakeNftERC11155, address.Cook, true)
        await DeployedContractCook.setTimeForReward(process.env.TIME_FOR_REWARD)

        //shrine
        await approveContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721, address.PowerPlinsGen0ERC721, address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.BossCardERC1155, address.BossCardERC1155, address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.Shrine)
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155, address.PancakeNftERC11155, address.Shrine, true)
        await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155, address.Gen1ERC1155, address.Shrine, true)


    }
    if(printTime){
        await ErrandGen0Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)
        await ErrandGen1Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)
        await DeployedContractCook.setTimeForReward(process.env.TIME_FOR_REWARD)
        await DeployedContractShrine.setTimeForReward(process.env.TIME_FOR_REWARD)
        await DeployedErrandBossCardStake.setTimeForReward(process.env.TIME_FOR_REWARD)
        const gen0 = await ErrandGen0Deploy.timeForReward()
        console.log("time for",{gen0})
        const gen1 = await ErrandGen1Deploy.timeForReward()
        console.log("time for",{gen1})
        const cook= await DeployedContractCook.timeForReward()
        console.log("time for",{cook})
        const shrine =  await DeployedContractShrine.timeForReward()
        console.log("time for",{shrine})
        const errandBoss =  await DeployedErrandBossCardStake.timeForReward()
        console.log("time for",{errandBoss})
    }

}
main()
