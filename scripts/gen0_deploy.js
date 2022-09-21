const {getMerkleRoot,CONTRACT_NAME_MAP,deployWithVerifyContract} = require("../utils/common");

async function main() {
    const [name, symbol,presaleCost,cost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    console.log("name, symbol, presaleCost,cost, maxSupply, hiddenUri, merkleRoot",name, symbol, presaleCost, cost,maxSupply, hiddenUri,merkleRoot)
    await deployWithVerifyContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721New,[name, symbol, presaleCost,cost, maxSupply, hiddenUri, merkleRoot],true)
}
main();

