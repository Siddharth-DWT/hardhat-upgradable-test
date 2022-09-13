const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
//const { ethers, upgrades} = require("hardhat");
async function main() {

    const {PowerPlinsGen0ERC721,Gen1ERC1155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,CommonConstGen1, ErrandBossCardStake} = address
    if(!CommonConstGen0){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[])
    }
    if(!CommonConstGen1){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen1,[])
    }
    if(!ErrandBossCardStake){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.ErrandBossCardStake,[BossCardERC1155])
    }

    // Deploying Gen1
    await deployProxyContract(CONTRACT_NAME_MAP.ErrandGen0,[PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,CommonConstGen0,ErrandBossCardStake])
    await deployProxyContract(CONTRACT_NAME_MAP.ErrandGen1,[Gen1ERC1155,IngredientsERC11155,CommonConstGen1,ErrandBossCardStake])
}
main();

