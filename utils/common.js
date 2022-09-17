const { ethers, upgrades,} = require("hardhat");
const hardhat = require("hardhat");

const {MerkleTree} = require('merkletreejs');
const keccak256 = require('keccak256');

const promisify = require('util').promisify;
const fs = require('fs');
const address = require("../address.json");
const writeFile = promisify(fs.writeFile);
const readFile = promisify(fs.readFile);
const Web3 = require('web3');

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
    Cook:"Cook",
    ShrineConst:"ShrineConst",
    Shrine:"Shrine",
    SignatureChecker:"SignatureChecker",
    PowerPlinsGen0ERC721Royalty:"PowerPlinsGen0ERC721Royalty"
 }


async function deployWithVerifyContract(contractName,params, notVerify){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName);
    const deployedContract = await Contract.deploy(...params);
    await deployedContract.deployTransaction.wait(10);

    console.log(`${contractName} deployed to:`, deployedContract.address);
    writeAddress(contractName,deployedContract.address)
    if(!notVerify){
        console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);
        try{
            await hardhat.run('verify:verify', {
                address: deployedContract.address,
                constructorArguments: [...params],
                contract: `contracts/${contractName}.sol:${contractName}`,
            });
        }
        catch (e){
            console.log("error",e)
        }
    }
    return deployedContract.address;

}

async function deployProxyContract(contractName, params){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName);
    const deployedContract = await upgrades.deployProxy(Contract,[...params]);
    await deployedContract.deployTransaction.wait(10);
    console.log(deployedContract.address,` ${contractName}(proxy) address`)
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(deployedContract.address)
    console.log(implementationAddress," getImplementationAddress")
    console.log(await upgrades.erc1967.getAdminAddress(deployedContract.address)," getAdminAddress")

    await verifyContract(contractName,implementationAddress,params)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);

    await writeAddress(contractName,deployedContract.address)
    await writeAddress(contractName+"_IMP",implementationAddress)

    //console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);

    
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
async function verifyProxyContract(contractName,address,params){
    console.log("contractName,address,params",contractName,address,params)
    console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);

    const Contract = await ethers.getContractFactory(contractName);
    const DeployedContract = Contract.attach(address);

    const res1 = await DeployedContract.ingredientsERC1155()
    const res2 = await DeployedContract.bossCardERC1155Address()
    console.log("res-----",res1);
    console.log("res-----",res2);
}

async function approveContract(contractName,contractAddress, approvalAddress, isMint){
    const Contract = await ethers.getContractFactory(contractName);
    const DeployedContract = Contract.attach(contractAddress);
    if(isMint){
        await DeployedContract.setMintApprovalForAll(approvalAddress, true)
    }else {
        await DeployedContract.setApprovalForAll(approvalAddress, true)
    }
    console.log(`address ${approvalAddress} ${isMint?'mint':''} approved on ${contractName} `)
}

function generateSignature(sender,id,key,value){
    console.log({sender,id,key,value})
    const privateKey = process.env.PRI_KEY
    let message;
    if(sender && id && key && value){
        message = Web3.utils.soliditySha3(sender,id,key,value);
    }
    else if(sender && id){
        message = Web3.utils.soliditySha3(sender, id);
    }
    else if(sender){
        message = Web3.utils.soliditySha3(sender);
    }
    const web3 = new Web3('');

    const {signature} = web3.eth.accounts.sign(
        message,
        privateKey
    );
    console.log("---signature---", signature)
    return {message,signature}

}


module.exports = {
    getMerkleRoot,
    CONTRACT_NAME_MAP,
    scan_link,
    writeAddress,
    deployWithVerifyContract,
    verifyContract,
    deployProxyContract,
    verifyProxyContract,
    approveContract,
    generateSignature

}


