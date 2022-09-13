const {CONTRACT_NAME_MAP, verifyProxyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
async function main(){
    const {IngredientsERC11155,BossCardERC1155,PancakeNftERC11155, Gen1ERC1155, ErrandGen0,ErrandGen1, Cook} = address

    const Ingredient = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
    const IngredientContract = Ingredient.attach(address.IngredientsERC11155);

    const BossCard = await ethers.getContractFactory(CONTRACT_NAME_MAP.BossCardERC1155);
    const BossContract = BossCard.attach(address.BossCardERC1155);

    const Pancake = await ethers.getContractFactory(CONTRACT_NAME_MAP.PancakeNftERC11155);
    const PancakeContract = Pancake.attach(address.PancakeNftERC11155);

    const Gen1 = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const Gen1Contract = Gen1.attach(address.Gen1ERC1155);
    await IngredientContract.setMintApprovalForAll(ErrandGen0, true)
    await IngredientContract.setMintApprovalForAll(ErrandGen1, true)
    await PancakeContract.setMintApprovalForAll(Cook,true)
    //await PancakeContract.setMintApprovalForAll(Cook,true)
    //await PancakeContract.setMintApprovalForAll(Cook,true)


}
main()
