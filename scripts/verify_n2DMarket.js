const {verifyContract,CONTRACT_NAME_MAP} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const {n2DMarket} = address

    await verifyContract(CONTRACT_NAME_MAP.n2DMarket,n2DMarket,[])
}
main()
