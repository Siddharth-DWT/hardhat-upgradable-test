const { ethers, upgrades,} = require("hardhat");
const hardhat = require("hardhat");

const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');

const promisify = require('util').promisify;
const fs = require('fs');
const writeFile = promisify(fs.writeFile);
const readFile = promisify(fs.readFile);

const scan_link=  "https://testnet.arbiscan.io/address/"

const writeAddress = async (key,address) =>{
    const link = scan_link+address;
    const configJson = await readFile('address.json', 'utf-8');
    const config = JSON.parse(configJson);
    Object.assign(config, {[key]:address},{[key+"_LINK"]:link});
    await writeFile(
        'address.json',
        JSON.stringify(config, null, 2)
    );
}

const getMerkleRoot = (addresses)=>{
    addresses = JSON.parse(addresses)
    const leaves = addresses.map(x => keccak256(x))
    const tree = new MerkleTree(leaves, keccak256, { sortPairs: true })
    const buf2hex = x => '0x' + x.toString('hex')
    const root = buf2hex(tree.getRoot());
    console.log(buf2hex(tree.getRoot()))
    return root;
}

 const CONTRACT_NAME_MAP = {
    PowerPlinsGen0ERC721: "PowerPlinsGen0ERC721",
    BossCardERC1155: "BossCardERC1155",
    Gen1ERC1155: "Gen1ERC1155",
    IngredientsERC11155: "IngredientsERC11155",
    PancakeNftERC11155: "PancakeNftERC11155",
    ErrandGen0:"ErrandGen0",
    ErrandGen1:"ErrandGen1",
    CommonConstGen0:"CommonConstGen0",
    CommonConstGen1:"CommonConstGen1",
    ErrandBossCardStake:"ErrandBossCardStake",
 }
async function deployProxyContract(contractName, params){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName);
    const deployedContract = await upgrades.deployProxy(Contract,[...params],{
        initializer: "initialize", kind: "uups" });

    //const deployedContract = await Contract.deploy();
    await deployedContract.deployTransaction.wait(10);
    console.log("deployedContract",deployedContract);

    console.log(`${contractName} deployed to:`, deployedContract.address);
    writeAddress(contractName,deployedContract.address)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: deployedContract.address,
            constructorArguments: [...params],
           // {initializer: "initialize", kind: "uups"}
        });

    }
    catch (e){
        console.log("error",e)
    }
}

async function deployWithVerifyContract(contractName,params){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName);
    const deployedContract = await Contract.deploy(...params);
    await deployedContract.deployTransaction.wait(10);

    console.log(`${contractName} deployed to:`, deployedContract.address);
    writeAddress(contractName,deployedContract.address)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: deployedContract.address,
            constructorArguments: [...params]
        });
    }
    catch (e){
        console.log("error",e)
    }
    return deployedContract.address;

}

async function verifyContract(contractName,address,params){
    console.log("contractName,address,params",contractName,address,params)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: address,
            constructorArguments: [...params],
            contract: `contracts/${contractName}.sol:${contractName}`,
        });
    }
    catch (e){
        console.log("error",e)
    }
}

async function deployContractWithOpt(contractName,params,opt){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName,opt);
    const deployedContract = await Contract.deploy(...params);
    await deployedContract.deployTransaction.wait(10);

    console.log(`${contractName} deployed to:`, deployedContract.address);
    writeAddress(contractName,deployedContract.address)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: deployedContract.address,
            constructorArguments: [...params]
        });
    }
    catch (e){
        console.log("error",e)
    }
    return deployedContract.address;

}

module.exports = {
    getMerkleRoot,
    CONTRACT_NAME_MAP,
    scan_link,
    writeAddress,
    deployWithVerifyContract,
    verifyContract,
    deployProxyContract,
    deployContractWithOpt
}


