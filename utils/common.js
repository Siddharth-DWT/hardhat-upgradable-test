const { ethers, upgrades,} = require("hardhat");
const hardhat = require("hardhat");

// const {MerkleTree} = require('merkletreejs');
// const keccak256 = require('keccak256');

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

 const CONTRACT_NAME_MAP = {
    Collection:"Collection",
    NFTMarketResell:"NFTMarketResell",
    n2DMarket:"n2DMarket",
    N2DNFT:"N2DNFT"
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

async function approveContract(contractName,contractAddress, approvalAddress, isMint, approvalFrom = "approvalFrom"){
    const Contract = await ethers.getContractFactory(contractName);
    const DeployedContract = Contract.attach(contractAddress);
    if(isMint){
        await DeployedContract.setMintApprovalForAll(approvalAddress, true)
    }else {
        await DeployedContract.setApprovalForAll(approvalAddress, true)
    }
    console.log(`address ${approvalAddress} of ${approvalFrom} ${isMint?'mint':''} approved on ${contractName} `)
}


function getHash(title, num, arr, num2) {
    let args = []
    arr.map((addr, index) => {
        args[index] = {t: 'bytes', v: Web3.utils.leftPad(addr, 64)}
    })
    return web3.utils.soliditySha3(
        {t: 'string', v: title},
        {t: 'uint256', v: num},
        ...args,
        {t: 'uint256', v: num2}
    );
}
function getArguments(arr){
    let args = []
    arr.map((num, index) => {
        args[index] = {t: 'uint256', v: num}
    })
    return args;
}

module.exports = {
    CONTRACT_NAME_MAP,
    scan_link,
    writeAddress,
    deployWithVerifyContract,
    verifyContract,
    approveContract
}


