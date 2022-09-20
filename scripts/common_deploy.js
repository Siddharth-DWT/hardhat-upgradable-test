const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")

const deployConst = true;
async function main() {
    const {BossCardERC1155,CommonConstGen0,CommonConstGen1, ErrandBossCardStake} = address
    if(deployConst || !CommonConstGen0){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[],true)
    }
    if(deployConst || !CommonConstGen1){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen1,[],true)
    }
    if(deployConst || !ErrandBossCardStake){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.ErrandBossCardStake,[BossCardERC1155])
    }

    let {CookConst,ShrineConst,SignatureChecker} = address;
    if(deployConst || !CookConst){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CookConst,[],true)
    }

    if(deployConst || !ShrineConst){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.ShrineConst,[],true)
    }
    if(deployConst || !SignatureChecker){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.SignatureChecker,[], false)
    }

}
main();

