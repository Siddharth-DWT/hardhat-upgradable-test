const { ethers} = require("hardhat");
//import { Contract, ContractFactory } from 'ethers';
const hardhat = require("hardhat");
const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');
const promisify = require('util').promisify;
const fs = require('fs');
const writeFile = promisify(fs.writeFile);
const readFile = promisify(fs.readFile);

const getMerkleRoot = (addresses)=>{
    addresses = JSON.parse(addresses)
     const leaves = addresses.map(x => keccak256(x))
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })
    const buf2hex = x => '0x' + x.toString('hex')
    const root = buf2hex(tree.getRoot());
    console.log(buf2hex(tree.getRoot()))
    return root;
}


const writeAddress = async (key,address) =>{
    const configJson = await readFile('address.json', 'utf-8');
    const config = JSON.parse(configJson);
    Object.assign(config, {[key]:address});
    await writeFile(
        'address.json',
        JSON.stringify(config, null, 2)
    );
}


async function main() {
    const [name, symbol, presaleCost, maxSupply, hiddenUri] = process.env.GEN0_PARAMS.split(",")
    const merkleRoot = getMerkleRoot(process.env.WHITELIST_ADDRESSES)
    console.log("Deploying...");
    writeAddress("PowerPlinsGen0ERC721","gen0.address")
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
    writeAddress("PowerPlinsGen0ERC721",gen0.address)

    /**
     * Verify Contracts
     */
    console.log(`Verifying PowerPlinsGen0ERC721 on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: gen0.address,
            constructorArguments: [ name,
                symbol,
                presaleCost,
                maxSupply,
                hiddenUri,
                merkleRoot]
        });
    }catch (e){
        console.log("error",e)
    }
}

main();

