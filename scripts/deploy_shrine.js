const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
//const { ethers, upgrades} = require("hardhat");

async function main() {

    const {PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,Gen1ERC1155,PancakeNftERC11155,CheckSigner} = address
    await deployProxyContract(CONTRACT_NAME_MAP.ShrineStake,[PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,Gen1ERC1155,PancakeNftERC11155,CheckSigner])

main();



