const {CONTRACT_NAME_MAP, verifyProxyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
//[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25],[10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10]
async function main(){
/*    const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen0);
    const ErrandGen0Deploy = ErrandGen0Contract.attach(address.ErrandGen0);
    const timeReward = await ErrandGen0Deploy._timeForReward()
    console.log("timeReward",timeReward);
    await ErrandGen0Deploy.setTimeForReward(240)
    const timeReward1 = await ErrandGen0Deploy._timeForReward()
    console.log("timeReward1",timeReward1);*/

    const ErrandGen1Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen1);
    const ErrandGen1Deploy = ErrandGen1Contract.attach(address.ErrandGen1);
    const timeReward = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward",timeReward);
    await ErrandGen1Deploy.setTimeForReward(240)
    const timeReward1 = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward1",timeReward1);


    let response = await ErrandGen1Deploy.stake([1,2]);
    console.log("response",response);


}
main()
