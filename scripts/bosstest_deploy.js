const {CONTRACT_NAME_MAP, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")

async function main(){
    await deployWithVerifyContract(CONTRACT_NAME_MAP.BossCardERC1155Test,[" "])

}
main()
