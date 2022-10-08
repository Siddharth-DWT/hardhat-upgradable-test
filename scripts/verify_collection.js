const {verifyContract,CONTRACT_NAME_MAP} = require("../utils/common")
const address= require("../address.json")

// const addr = "0x6Ec5C9621eaF9d55720d02F54C638aF4935FCd02";
async function main(){
    const {Collection} = address

    await verifyContract(CONTRACT_NAME_MAP.Collection,Collection,[])
}
main()
