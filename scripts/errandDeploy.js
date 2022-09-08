const {getMerkleRoot,CONTRACT_NAME_MAP,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json");

async function main() {

    const powerPlinAddr = address[CONTRACT_NAME_MAP.PowerPlinsGen0ERC721];
    const ingredientAddr = address[CONTRACT_NAME_MAP.IngredientsERC11155];
    const bosscardAddr = address[CONTRACT_NAME_MAP.BossCardERC1155];

    //const erandstake = await deployWithVerifyContract(CONTRACT_NAME_MAP.Errand);
    const erandstake = await ethers.getContractFactory("Errand");
    const Erandstake = await upgrades.deployProxy(erandstake, [powerPlinAddr, ingredientAddr, bosscardAddr], {
        initializer: "initialize", kind: "uups" });
    await Erandstake.deployed();

    console.log("Erandstake deployed to:", Erandstake.address);
}
main();
    
   

