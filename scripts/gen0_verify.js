const {verifyContract,CONTRACT_NAME_MAP,getMerkleRoot} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const [name, symbol, presaleCost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
    console.log("name, symbol, presaleCost, maxSupply, hiddenUri",name, symbol, presaleCost, maxSupply, hiddenUri)
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    await verifyContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721,address[CONTRACT_NAME_MAP.PowerPlinsGen0ERC721],[name, symbol, presaleCost, maxSupply, hiddenUri, merkleRoot])
}
main()
