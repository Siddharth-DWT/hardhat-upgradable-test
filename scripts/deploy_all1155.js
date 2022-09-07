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
    const {BOSS_CARD_URI,GEN1_URI,INGREDIENT_URI,PANCAKE_URI} = process.env;
    console.log("Deploying BosscardERC1155...");
    const BossCardERC1155 = await ethers.getContractFactory("BossCardERC1155");
    const bosscard = await BossCardERC1155.deploy(BOSS_CARD_URI);
    await bosscard.deployTransaction.wait(10);
    console.log("BosscardERC1155 deployed to:", bosscard.address);
    console.log('Verifying BosscardERC1155 on Rinkeby...');
    await hardhat.run('verify:verify', {
        address: bosscard.address,
        constructorArguments: [BOSS_CARD_URI]
    });

    console.log("Deploying Gen11155...");
    const Gen11155 = await ethers.getContractFactory("Gen11155");
    const gen1 = await Gen11155.deploy(GEN1_URI);
    await gen1.deployTransaction.wait(10);
    console.log("Gen11155 deployed to:", gen1.address);
    console.log('Verifying Gen11155 on Rinkeby...');
    await hardhat.run('verify:verify', {
        address: gen1.address,
        constructorArguments: [GEN1_URI]
    });

    console.log("Deploying IngredientERC1155...");
    const IngredientERC1155 = await ethers.getContractFactory("IngredientERC1155");
    const ingredient = await IngredientERC1155.deploy(INGREDIENT_URI);
    await ingredient.deployTransaction.wait(10);
    console.log("IngredientERC1155 deployed to:", ingredient.address);
    console.log('Verifying IngredientERC1155 on Rinkeby...');
    await hardhat.run('verify:verify', {
        address: ingredient.address,
        constructorArguments: [INGREDIENT_URI]
    });

    console.log("Deploying PancakeERC1155...");
    const PancakeERC1155 = await ethers.getContractFactory("PancakeERC1155");
    const pancake = await PancakeERC1155.deploy(PANCAKE_URI);
    await pancake.deployTransaction.wait(10);
    console.log("PancakeERC1155 deployed to:", pancake.address);
    console.log('Verifying PancakeERC1155 on Rinkeby...');
    await hardhat.run('verify:verify', {
        address: pancake.address,
        constructorArguments: [PANCAKE_URI]
    });

}

main();

