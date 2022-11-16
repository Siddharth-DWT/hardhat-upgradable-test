const {CONTRACT_NAME_MAP, approveContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const updateUri = false;

async function main(){

    const Gen1ERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const Gen1ERC1155Deploy = Gen1ERC1155.attach(address.Gen1ERC1155);

    if(updateUri){
        let tokenId = 510;
        let uri = await Gen1ERC1155Deploy.uri(tokenId);
        uri = uri.toString();
        console.log(`Token uri of ${tokenId} before update is: ${uri}`);

        const newUri = "https://powerplins.mypinata.cloud/ipfs/QmSJays73qPHycnx63hAWBxNMFvtprStbJG4FVXMhiPPHo/";
        const updateUri = await Gen1ERC1155Deploy.setURI(newUri);
        console.log("updateUri response",updateUri);

        let uriUpdate = await Gen1ERC1155Deploy.uri(tokenId);
        uriUpdate = uriUpdate.toString();
        console.log(`Token uri of ${tokenId} after update is: ${uriUpdate}`);
    }
}
main()


