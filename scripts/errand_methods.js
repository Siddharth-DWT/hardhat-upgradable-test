const {CONTRACT_NAME_MAP, verifyProxyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
//[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25],[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10]
async function main(){

    //approval
  /*  const PowerPlinsGen0ERC721 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721);
    const PowerPlinsGen0ERC721Deploy = PowerPlinsGen0ERC721.attach(address.PowerPlinsGen0ERC721);
    PowerPlinsGen0ERC721Deploy.setApprovalForAll(address.ErrandGen0, true)*/

    const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen0);
    const ErrandGen0Deploy = ErrandGen0Contract.attach(address.ErrandGen0);

    console.log("PowerPlinsGen0ERC721 aprrovale");

   /* let timeReward = await ErrandGen0Deploy._timeForReward()
    console.log("timeReward",timeReward);
    await ErrandGen0Deploy.setTimeForReward(240)
    let timeReward1 = await ErrandGen0Deploy._timeForReward()
    console.log("timeReward1",timeReward1);*/

 /*   var response = await ErrandGen0Deploy.stake([29]);
    console.log("ErrandGen0Deploy stake",response);*/

    var response = await ErrandGen0Deploy.printTotalTokenStake();
    console.log("printTotalTokenStake gen1",response);


    //approval
    /*const Gen1ERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const Gen1ERC1155Deploy = Gen1ERC1155.attach(address.Gen1ERC1155);
    Gen1ERC1155Deploy.setApprovalForAll(address.ErrandGen1, true)
    console.log("Gen1ERC1155 aprrovale");*/

    const ErrandGen1Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen1);
    const ErrandGen1Deploy = ErrandGen1Contract.attach(address.ErrandGen1);

   /* timeReward = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward",timeReward);
    await ErrandGen1Deploy.setTimeForReward(240)
    timeReward1 = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward1",timeReward1);*/


/*     response = await ErrandGen1Deploy.stake([11,12]);
    console.log("stake gen1",response);*/

    response = await ErrandGen1Deploy.printTotalTokenStake();
    console.log("printTotalTokenStake gen1",response);



}
main()
