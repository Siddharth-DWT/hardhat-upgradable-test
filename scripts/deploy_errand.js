const {getMerkleRoot,CONTRACT_NAME_MAP,deployWithVerifyContract} = require("../utils/common");

async function main() {
    await deployWithVerifyContract(CONTRACT_NAME_MAP.Errand)
}
main();

