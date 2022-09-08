const { ethers, upgrades } = require("hardhat");

async function main() {

    const powerplins = await ethers.getContractFactory("powerplin");
    //powerplin contract constructor arguments pass to deploy powerplin contract
    const PowerPlins = await powerplins.deploy("https://ipfs.io/ipfs/bafybeicg2xxubrxepe4amujl7tmyok52juxsz534kk3skmdsq62w53fezy/");
    console.log("powerplins deployed to:", PowerPlins.address);

    const ingredient = await ethers.getContractFactory("IngredientERC11155");
    //ingredient contract constructor arguments pass to deploy ingredient contract
    const Ingredient = await ingredient.deploy("https://ipfs.io/ipfs/bafybeicg2xxubrxepe4amujl7tmyok52juxsz534kk3skmdsq62w53fezy/");
    console.log("Ingredient deployed to:", Ingredient.address);

    const gen1stake = await ethers.getContractFactory("Gen1Stake");
    //gen1Stake contract constructor arguments pass to deploy gen1Stake contract
    const Gen1Stake = await upgrades.deployProxy(gen1stake, [PowerPlins.address, Ingredient.address], {
        initializer: "initialize", kind: "uups" });
    await Gen1Stake.deployed();

    console.log("Gen1Stake deployed to:", Gen1Stake.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});

