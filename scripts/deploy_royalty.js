const {getMerkleRoot,CONTRACT_NAME_MAP,deployWithVerifyContract} = require("../utils/common");
const {ethers} = require("hardhat");
const address = require("../address.json");

async function main() {
    const [name, symbol, presaleCost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
    console.log("name, symbol, presaleCost, maxSupply, hiddenUri",name, symbol, presaleCost, maxSupply, hiddenUri)
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    await deployWithVerifyContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721Royalty,[name, symbol, presaleCost, maxSupply, hiddenUri, merkleRoot])
    const Gen0 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721Royalty);
    const Gen0Contract = Gen0.attach(address.PowerPlinsGen0ERC721Royalty);
    await Gen0Contract.mint(process.env.OWNER,3)

}
main();

