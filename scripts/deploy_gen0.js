const {getMerkleRoot,CONTRACT_NAME_MAP,deployWithVerifyContract} = require("../utils/common");

async function main() {
    const [name, symbol, presaleCost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
    console.log("name, symbol, presaleCost, maxSupply, hiddenUri",name, symbol, presaleCost, maxSupply, hiddenUri)
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    await deployWithVerifyContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721,[name, symbol, presaleCost, maxSupply, hiddenUri, merkleRoot])
}
main();

