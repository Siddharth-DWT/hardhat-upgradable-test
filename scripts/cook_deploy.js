const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
//const { ethers, upgrades} = require("hardhat");
const deployConst = false;
async function main() {
    const {IngredientsERC11155,BossCardERC1155,PancakeNftERC11155} = address
    let {CookConst} = address;
    if(deployConst || !CookConst){
        CookConst = await deployWithVerifyContract(CONTRACT_NAME_MAP.CookConst,[])
    }
    await deployProxyContract(CONTRACT_NAME_MAP.Cook,[IngredientsERC11155,BossCardERC1155,PancakeNftERC11155,CookConst])
}
main();

