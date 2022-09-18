const {CONTRACT_NAME_MAP, approveContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const {parse} = require("dotenv");
const executeBase = true;
const stakes = [1,2], stakeData = false;
async function main(){
    const Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Cook);
    const DeployedContract = Contract.attach(address.Cook);

    if(executeBase){
        const timeReward = await DeployedContract.timeForReward()
        console.log("timeReward",timeReward);
        await DeployedContract.setTimeForReward(process.env.TIME_FOR_REWARD)
        const timeReward1 = await DeployedContract.timeForReward()
        console.log("timeReward1",timeReward1);

        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,address.IngredientsERC11155,address.Cook)
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.Cook, true)

    }

    var response = await DeployedContract.printUserIngredientStakes()
    console.log("response",response);

    if(stakeData){
        var input = [[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1],[[1,2,3,4,5,6,7,8],[1,1,1,1,1,1,1,1],1]]
        await DeployedContract.stake(input)
        console.log("stake done1");
        input = [
            [[25],[1],1],
        ]
        await DeployedContract.stake(input)
        console.log("stake done2");
    }


    var response = await DeployedContract.printUserIngredientStakes()
    console.log("response",response);
    //console.log("times",parse(response[4][0]));


    /*const claim = await DeployedContract.claimReward(stakes[1])
   console.log("cliaim",claim);*/
}
main()
