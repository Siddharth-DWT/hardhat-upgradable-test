const { ethers} = require("hardhat");
//import { Contract, ContractFactory } from 'ethers';
const hardhat = require("hardhat");
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');

const getMerkleRoot = (addresses)=>{
    addresses = JSON.parse(addresses)
     const leaves = addresses.map(x => keccak256(x))
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })
    const buf2hex = x => '0x' + x.toString('hex')
    const root = buf2hex(tree.getRoot());
    console.log(buf2hex(tree.getRoot()))
    return root;
}

async function main() {
    const [name, symbol, presaleCost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
   // console.log("process.env -ame, symbol, presaleCost, maxSupply, hiddenUri",name, symbol, presaleCost, maxSupply, hiddenUri)
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    //console.log("merkleRoot",merkleRoot)
    console.log("Deploying...");
    const PowerPlinsGen0 = await ethers.getContractFactory("PowerPlinsGen0ERC721");
    const gen0 = await PowerPlinsGen0.deploy(
        name,
        symbol,
        presaleCost,
        maxSupply,
        hiddenUri,
        merkleRoot
    );
    await gen0.deployTransaction.wait(10);
    console.log("PowerPlinsGen0ERC721 deployed to:", gen0.address);

    /**
     * Verify Contracts
     */
    console.log('Verifying PowerPlinsGen0ERC721 on Rinkeby...');
    await hardhat.run('verify:verify', {
        address: gen0.address,
        constructorArguments: [ name,
            symbol,
            presaleCost,
            maxSupply,
            hiddenUri,
            merkleRoot]
    });
}

main();

