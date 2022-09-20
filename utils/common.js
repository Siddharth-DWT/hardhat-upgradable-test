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
     PowerPlinsGen0ERC721Today:"PowerPlinsGen0ERC721Today",
    BossCardERC1155: "BossCardERC1155",
    Gen1ERC1155: "Gen1ERC1155",
    IngredientsERC11155: "IngredientsERC11155",
    PancakeNftERC11155: "PancakeNftERC11155",
    SignatureChecker:"SignatureChecker",
    CommonConstGen0:"CommonConstGen0",
    CommonConstGen1:"CommonConstGen1",
    ErrandBossCardStake:"ErrandBossCardStake",
    ErrandGen0:"ErrandGen0",
    ErrandGen1:"ErrandGen1",
    CookConst:"CookConst",
    Cook:"Cook",
    ShrineConst:"ShrineConst",
    Shrine:"Shrine",
    Feed:"Feed",
     CommonConstGenNew:"CommonConstGenNew"
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
function generateFeedRevealSignature(sender,val1,val2,val3){
    console.log({sender,val1,val2,val3})
    const privateKey = process.env.PRI_KEY
   /* let message = Web3.utils.soliditySha3(sender,
    ...getArguments(val1),
    ...getArguments(val1),
    ...getArguments(val3))*/
    const web3 = new Web3('');

    let message = web3.utils.keccak256(web3.eth.abi.encodeParameters(['address','uint', 'uint','uint'], [sender,val1,val2,val3]))

    const {signature} = web3.eth.accounts.sign(
        message,
        privateKey
    );
    console.log("---signature---", signature)
    return {message,signature}

}

function generateSignature(sender,val1,val2,val3){
    console.log({sender,val1,val2,val3})
    const privateKey = process.env.PRI_KEY
    let message;
    if(sender && val1 && val2 && val3){
        message = Web3.utils.soliditySha3(sender,val1,val2,val3);
    }
    else if(sender && val1 && val2){
        message = Web3.utils.soliditySha3(sender, val1,val2);
    }
    else if(sender && val1){
        message = Web3.utils.soliditySha3(sender, val1);
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
    generateSignature,
    generateFeedRevealSignature

}


