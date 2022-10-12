const {CONTRACT_NAME_MAP,deployWithUpgradeContract} = require("../utils/common");
const address= require("../address.json");
const deployConst = true;

async function main() {
    const {Feed,PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker} = address;
    //await deployWithUpgradeContract(CONTRACT_NAME_MAP.FeedV1,Feed,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker]);
    await deployWithUpgradeContract(CONTRACT_NAME_MAP.FeedV2,Feed,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker]);

}
main();


