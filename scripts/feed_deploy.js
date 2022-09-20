const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
const deployConst = true;
async function main() {
    const {PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker} = address
    if(!CommonConstGen0){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[])
    }
    await deployProxyContract(CONTRACT_NAME_MAP.Feed,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker])
}
main();

