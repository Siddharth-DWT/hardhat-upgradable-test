const {CONTRACT_NAME_MAP, verifyProxyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
//[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25],[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10]
async function main(){
    const {IngredientsERC11155,BossCardERC1155,PancakeNftERC11155, Gen1ERC1155} = address

    const Ingredient = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
    const IngredientContract = Ingredient.attach(address.IngredientsERC11155);

    const BossCard = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
    const BossContract = BossCard.attach(address.BossCardERC1155);

    const Pancake = await ethers.getContractFactory(CONTRACT_NAME_MAP.PancakeNftERC11155);
    const PancakeContract = Pancake.attach(address.PancakeNftERC11155);

    const Gen1 = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const Gen1Contract = Gen1.attach(address.Gen1ERC1155);
    //console.log("ingredients mint")
    //await IngredientContract.mintBatch(process.env.OWNER,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25],[30,30,20,20,20,30,40,10,10,10,10,10,12,13,13,14,30,30,30,30,30,30,30,30,10])
    //console.log("bosscard mint")
    await BossContract.mintBatch(process.env.OWNER,[14,29,58,98,31,45,1,2,4,7,27,28,49,50,23,24],[30,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3])
    //console.log("pancake mint")
    //await PancakeContract.mintBatch(process.env.OWNER,[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19],[15,15,15,15,15,15,15,16,17,18,19,30,30,30,30,30,30,30,30])
    console.log("gen1 mint")
    await Gen1Contract.mintBatch(process.env.OWNER,[1,2,3,4,5,6,7,8,9,10],[3,3,3,3,3,3,3,3,3,3])


}
main()
