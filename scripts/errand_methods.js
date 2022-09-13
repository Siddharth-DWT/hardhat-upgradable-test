const {CONTRACT_NAME_MAP, verifyProxyContract, approveContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const runApproval = true;
const runSetTime = true;
const runStake = false;

async function main(){
    if(runApproval) {
        await approveContract(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721, address.PowerPlinsGen0ERC721, address.ErrandGen0)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.ErrandGen0, true)

        await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155, address.Gen1ERC1155, address.ErrandGen1)
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, address.IngredientsERC11155, address.ErrandGen1, true)
    }


    const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen0);
    const ErrandGen0Deploy = ErrandGen0Contract.attach(address.ErrandGen0);

    console.log("PowerPlinsGen0ERC721 aprrovale");
    if(runSetTime){
        //let timeReward = await ErrandGen0Deploy.timeForReward()
        //console.log("timeReward",timeReward);
        await ErrandGen0Deploy.setTimeForReward(240)
        //let timeReward1 = await ErrandGen0Deploy.timeForReward()
        //console.log("timeReward1",timeReward1);
    }
    if(runStake){
        //approval
        const PowerPlinsGen0ERC721 = await ethers.getContractFactory(CONTRACT_NAME_MAP.PowerPlinsGen0ERC721);
        const PowerPlinsGen0ERC721Deploy = PowerPlinsGen0ERC721.attach(address.PowerPlinsGen0ERC721);

        const gen0Tokens = await PowerPlinsGen0ERC721Deploy.walletOfOwner(process.env.OWNER);
        console.log("gen0Tokens---",gen0Tokens);
        var response = await ErrandGen0Deploy.stake([gen0Tokens[0]]);
        console.log("ErrandGen0Deploy stake",response);
        /*var response = await ErrandGen0Deploy.stake([gen0Tokens[1]]);
        console.log("ErrandGen0Deploy stake",response);
        var response = await ErrandGen0Deploy.stake([gen0Tokens[2]]);
        console.log("ErrandGen0Deploy stake",response);*/
    }

    var printTotalTokenStake = await ErrandGen0Deploy.printTotalTokenStake();
    console.log("printTotalTokenStake gen1",printTotalTokenStake);

  /*  var printUserStakes = await ErrandGen0Deploy.printUserStakes();
    console.log("printUserStakes gen1",printUserStakes);

    var printUserClaims = await  ErrandGen0Deploy.printUserClaims()
    console.log("claims",printUserClaims);*/

/*    const ErrandBossCardStake = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandBossCardStake);
    const ErrandBossCardStakeDeploy = ErrandBossCardStake.attach(address.ErrandBossCardStake);
    const getBossCountClaim = await ErrandBossCardStakeDeploy.getBossCountClaim("1663103581")
    console.log({getBossCountClaim})*/

    //approval
    /*const Gen1ERC1155 = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const Gen1ERC1155Deploy = Gen1ERC1155.attach(address.Gen1ERC1155);
    Gen1ERC1155Deploy.setApprovalForAll(address.ErrandGen1, true)
    console.log("Gen1ERC1155 aprrovale");*/

    /*const ErrandGen1Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.ErrandGen1);
    const ErrandGen1Deploy = ErrandGen1Contract.attach(address.ErrandGen1);

     timeReward = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward",timeReward);
    await ErrandGen1Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)
    timeReward1 = await ErrandGen1Deploy._timeForReward()
    console.log("timeReward1",timeReward1);


   /!* var response = await ErrandGen1Deploy.stake([17]);
    console.log("stake gen1",response)*!/;
    var response = await ErrandGen1Deploy.stake([19]);
    console.log("stake gen1",response);


    response = await ErrandGen1Deploy.printTotalTokenStake();
    console.log("printTotalTokenStake gen1",response);*/



}
main()
