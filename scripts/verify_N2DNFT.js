const {verifyContract,CONTRACT_NAME_MAP} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const {N2DNFT,n2DMarket} = address

    await verifyContract(CONTRACT_NAME_MAP.N2DNFT,N2DNFT,[n2DMarket])
}
main()
