const {verifyContract,CONTRACT_NAME_MAP, deployWithVerifyContract, deployProxyContract} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const {PowerPlinsGen0ERC721,Gen1ERC1155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,CommonConstGen1, ErrandBossCardStake} = address
    // Deploying Gen1
    await verifyContract(CONTRACT_NAME_MAP.ErrandGen0,address.ErrandGen0,[PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,CommonConstGen0,ErrandBossCardStake])
    await verifyContract(CONTRACT_NAME_MAP.ErrandGen1,address.ErrandGen1,[PowerPlinsGen0ERC721,IngredientsERC11155,CommonConstGen1,ErrandBossCardStake])
}
main()
