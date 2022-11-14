const {CONTRACT_NAME_MAP,deployWithUpgradeContract} = require("../utils/common");
const address= require("../address.json");
const deployConst = true;

async function main() {
    const {Feed,FeedV1_IMP,PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker,newPancakeNFTERC11155} = address;
    // if(!CommonConstGen0){
    //     await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[])
    // }

    await deployWithUpgradeContract(CONTRACT_NAME_MAP.FeedV2,Feed,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker,newPancakeNFTERC11155]);
}
main();


