const {CONTRACT_NAME_MAP, verifyProxyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

async function main(){
    const {IngredientsERC11155,BossCardERC1155,PancakeNftERC11155} = address
    // Deploying Gen1
    //await verifyProxyContract(CONTRACT_NAME_MAP.Cook,address.Cook_Proxy,[IngredientsERC11155,BossCardERC1155,PancakeNftERC11155])

    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Cook);
    const DeployedContract = Contract.attach(address.Cook_Proxy);
    const timeReward = await DeployedContract.getTimeForReward()
    console.log("timeReward",timeReward);
    await DeployedContract.setTimeForReward(process.env.TIME_FOR_REWARD)
    const timeReward1 = await DeployedContract.getTimeForReward()
    console.log("timeReward1",timeReward1);
}
main()
