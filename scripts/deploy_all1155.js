const { ethers} = require("hardhat");
const hardhat = require("hardhat");

const promisify = require('util').promisify;
const fs = require('fs');
const writeFile = promisify(fs.writeFile);
const readFile = promisify(fs.readFile);

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
    const {BOSS_CARD_URI,GEN1_URI,INGREDIENT_URI,PANCAKE_URI} = process.env;
    console.log("Deploying BosscardERC1155...");
    const BossCardERC1155 = await ethers.getContractFactory("BossCardERC1155");
    const bosscard = await BossCardERC1155.deploy(BOSS_CARD_URI);
    await bosscard.deployTransaction.wait(10);
    console.log("BosscardERC1155 deployed to:", bosscard.address);
    writeAddress("BossCardERC1155",bosscard.address)
    console.log('Verifying BosscardERC1155 on Rinkeby...');
    try{
        await hardhat.run('verify:verify', {
            address: bosscard.address,
            constructorArguments: [BOSS_CARD_URI]
        });
    }
    catch (e){
        console.log("error",e)
    }

    console.log("Deploying Gen11155...");
    const Gen11155 = await ethers.getContractFactory("Gen11155");
    const gen1 = await Gen11155.deploy(GEN1_URI);
    await gen1.deployTransaction.wait(10);
    console.log("Gen11155 deployed to:", gen1.address);
    writeAddress("Gen11155",gen1.address)

    console.log('Verifying Gen11155 on Rinkeby...');
    try{
        await hardhat.run('verify:verify', {
        address: gen1.address,
        constructorArguments: [GEN1_URI]
        });
    }
    catch (e){
        console.log("error",e)
    }

    console.log("Deploying IngredientERC1155...");
    const IngredientERC1155 = await ethers.getContractFactory("IngredientERC1155");
    const ingredient = await IngredientERC1155.deploy(INGREDIENT_URI);
    await ingredient.deployTransaction.wait(10);
    console.log("IngredientERC1155 deployed to:", ingredient.address);
    writeAddress("IngredientERC1155",ingredient.address)
    console.log('Verifying IngredientERC1155 on Rinkeby...');
    try{
        await hardhat.run('verify:verify', {
            address: ingredient.address,
            constructorArguments: [INGREDIENT_URI]
        });
    }catch (e){
        console.log("error",e)
    }

    console.log("Deploying PancakeERC1155...");
    const PancakeERC1155 = await ethers.getContractFactory("PancakeERC1155");
    const pancake = await PancakeERC1155.deploy(PANCAKE_URI);
    await pancake.deployTransaction.wait(10);
    console.log("PancakeERC1155 deployed to:", pancake.address);
    writeAddress("PancakeERC1155",pancake.address)
    console.log('Verifying PancakeERC1155 on Rinkeby...');
    try{
        await hardhat.run('verify:verify', {
            address: pancake.address,
            constructorArguments: [PANCAKE_URI]
        });
    }
    catch (e){
        console.log("error",e)
    }

}

main();

