const {CONTRACT_NAME_MAP,deployWithUpgradeContract,verifyContract} = require("../utils/common");
const address= require("../address.json");
const deployConst = true;

async function main() {
    const {Feed,FeedV1_IMP,PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker} = address;
    // if(!CommonConstGen0){
    //     await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[])
    // }

    //await deployWithUpgradeContract(CONTRACT_NAME_MAP.FeedV1,Feed);
    await verifyContract(CONTRACT_NAME_MAP.FeedV1,FeedV1_IMP,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker]);
}
main();