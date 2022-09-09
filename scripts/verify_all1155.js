const {verifyContract,CONTRACT_NAME_MAP} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const {BOSS_CARD_URI,GEN1_URI,INGREDIENT_URI,PANCAKE_URI} = process.env

    await verifyContract(CONTRACT_NAME_MAP.BossCardERC1155,address[CONTRACT_NAME_MAP.BossCardERC1155],[BOSS_CARD_URI])
    await verifyContract(CONTRACT_NAME_MAP.Gen1ERC1155,address[CONTRACT_NAME_MAP.Gen1ERC1155],[GEN1_URI])
    await verifyContract(CONTRACT_NAME_MAP.IngredientsERC11155,address[CONTRACT_NAME_MAP.IngredientsERC11155],[INGREDIENT_URI])
    await verifyContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address[CONTRACT_NAME_MAP.PancakeNftERC11155],[PANCAKE_URI])
}
main()
