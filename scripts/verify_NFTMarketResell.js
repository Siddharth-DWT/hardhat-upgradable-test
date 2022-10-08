const {verifyContract,CONTRACT_NAME_MAP} = require("../utils/common")
const address= require("../address.json")

async function main(){
    const {NFTMarketResell,Collection} = address

    await verifyContract(CONTRACT_NAME_MAP.NFTMarketResell,NFTMarketResell,[Collection])
}
main()
