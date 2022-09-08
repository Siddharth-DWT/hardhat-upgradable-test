const { ethers, upgrades } = require("hardhat");

async function main() {

    const ingredient = await ethers.getContractFactory("IngredientsERC11155");
    //ingredient contract constructor arguments pass to deploy ingredient contract
    const Ingredient = await ingredient.deploy("https://ipfs.io/ipfs/bafybeicg2xxubrxepe4amujl7tmyok52juxsz534kk3skmdsq62w53fezy/");
    console.log("Ingredient deployed to:", Ingredient.address);

    const bosscard = await ethers.getContractFactory("BossCardERC1155");
    //bosscard contract constructor arguments pass to deploy bosscard contract
    const Bosscard = await bosscard.deploy("https://ipfs.io/ipfs/bafybeicg2xxubrxepe4amujl7tmyok52juxsz534kk3skmdsq62w53fezy/");
    console.log("Bosscard deployed to:", Bosscard.address);

    const pancake = await ethers.getContractFactory("PancakeNftERC11155");
    //pancake contract constructor arguments pass to deploy pancake contract
    const PanCake = await pancake.deploy("https://ipfs.io/ipfs/bafybeicg2xxubrxepe4amujl7tmyok52juxsz534kk3skmdsq62w53fezy/");
    console.log("PanCake deployed to:", PanCake.address);

    const cookingredient = await ethers.getContractFactory("CookIngredients");
    //cookingredient contract constructor arguments pass to deploy cookingredient contract
    const Cookingredient = await upgrades.deployProxy(cookingredient, [Ingredient.address, Bosscard.address, PanCake.address], {
        initializer: "initialize", kind: "uups" });
    await Cookingredient.deployed();

    console.log("Cookingredient deployed to:", Cookingredient.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});

