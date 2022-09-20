const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
const deployConst = false;
async function main() {
    const {PowerPlinsGen0ERC721, IngredientsERC11155,BossCardERC1155,PancakeNftERC11155,Gen1ERC1155} = address;
    let {ShrineConst,SignatureChecker} = address;
    if(deployConst || !ShrineConst){
        ShrineConst = await deployWithVerifyContract(CONTRACT_NAME_MAP.ShrineConst,[])
    }
    /*if(!SignatureChecker){
        SignatureChecker = await deployWithVerifyContract(CONTRACT_NAME_MAP.SignatureChecker,[], false)
    }*/
    await deployProxyContract(CONTRACT_NAME_MAP.Shrine,[PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,Gen1ERC1155,PancakeNftERC11155,ShrineConst, SignatureChecker])
}
main();

