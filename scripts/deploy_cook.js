const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
//const { ethers, upgrades} = require("hardhat");
async function main() {
    const {IngredientsERC11155,BossCardERC1155,PancakeNftERC11155} = address
    await deployProxyContract(CONTRACT_NAME_MAP.Cook,[IngredientsERC11155,BossCardERC1155,PancakeNftERC11155])
}
main();

