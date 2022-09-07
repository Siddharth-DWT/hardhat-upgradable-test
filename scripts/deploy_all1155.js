const {deployWithVerifyContract,CONTRACT_NAME_MAP} = require("../utils/common")

async function main(){
    const {BOSS_CARD_URI,GEN1_URI,INGREDIENT_URI,PANCAKE_URI} = process.env
    await deployWithVerifyContract(CONTRACT_NAME_MAP.BossCardERC1155,[BOSS_CARD_URI])
    await deployWithVerifyContract(CONTRACT_NAME_MAP.Gen1ERC1155,[GEN1_URI])
    await deployWithVerifyContract(CONTRACT_NAME_MAP.IngredientsERC11155,[INGREDIENT_URI])
    await deployWithVerifyContract(CONTRACT_NAME_MAP.PancakeNftERC11155,[PANCAKE_URI])
}

/*async function main() {
    console.log("CONTRACT_NAME_MAP",CONTRACT_NAME_MAP)
    const {BOSS_CARD_URI,GEN1_URI,INGREDIENT_URI,PANCAKE_URI} = process.env;
    console.log("Deploying BosscardERC1155...");

    const BossCardERC1155 = await ethers.getContractFactory("BossCardERC1155");
    const bosscard = await BossCardERC1155.deploy(BOSS_CARD_URI);
    await bosscard.deployTransaction.wait(10);
    console.log("BosscardERC1155 deployed to:", bosscard.address);
    writeAddress(CONTRACT_NAME_MAP.BossCardERC1155,bosscard.address)
    console.log(`Verifying BosscardERC1155 on ${process.env.DEPLOY_ENV}...`);
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
    const Gen11155 = await ethers.getContractFactory("Gen1ERC1155");
    const gen1 = await Gen11155.deploy(GEN1_URI);
    await gen1.deployTransaction.wait(10);
    console.log("Gen11155 deployed to:", gen1.address);
    writeAddress("Gen1ERC1155",gen1.address)

    //console.log('Verifying Gen11155 on Rinkeby...');
    console.log(`Verifying Gen11155 on ${process.env.DEPLOY_ENV}...`);
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
    const IngredientERC1155 = await ethers.getContractFactory("IngredientsERC11155");
    const ingredient = await IngredientERC1155.deploy(INGREDIENT_URI);
    await ingredient.deployTransaction.wait(10);
    console.log("IngredientsERC11155 deployed to:", ingredient.address);
    writeAddress("IngredientsERC11155",ingredient.address)
    //console.log('Verifying IngredientERC1155 on Rinkeby...');
    console.log(`Verifying IngredientERC1155 on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: ingredient.address,
            constructorArguments: [INGREDIENT_URI]
        });
    }catch (e){
        console.log("error",e)
    }

    console.log("Deploying PancakeERC1155...");
    const PancakeERC1155 = await ethers.getContractFactory("PancakeNftERC11155");
    const pancake = await PancakeERC1155.deploy(PANCAKE_URI);
    await pancake.deployTransaction.wait(10);
    console.log("PancakeNftERC11155 deployed to:", pancake.address);
    writeAddress("PancakeNftERC11155",pancake.address)
    //console.log('Verifying PancakeERC1155 on Rinkeby...');
    console.log(`Verifying PancakeNftERC11155 on ${process.env.DEPLOY_ENV}...`);
    try{
        await hardhat.run('verify:verify', {
            address: pancake.address,
            constructorArguments: [PANCAKE_URI]
        });
    }
    catch (e){
        console.log("error",e)
    }

}*/

main();

