const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
async function main() {
    const {PancakeNftERC11155,Gen1ERC1155, SignatureChecker} = address
    await deployProxyContract(CONTRACT_NAME_MAP.Event,[Gen1ERC1155,PancakeNftERC11155,SignatureChecker])
}
main();

