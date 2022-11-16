const {CONTRACT_NAME_MAP, verifyProxyContract, approveContract, generateSignature} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
const runApproval = true;
const runSetTime = false;
const runStake = false;
const runClaimReward = true
const legionTokenId=226
const runUnStake = false;
const setUnClaimed = false;

async function main(){
    const {Legions,PancakeNftERC11155,Gen1ERC1155} = address
    const EventContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Event);
    const EventGen0Deploy = EventContract.attach(address.Event);

  /*
    const PancakeNftERC11155Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.PancakeNftERC11155);
    const DeployedPancakeNftERC11155Contract= PancakeNftERC11155Contract.attach(address.PancakeNftERC11155);

    const Gen1ERC1155Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.Gen1ERC1155);
    const DeployedGen1ERC1155Contract = Gen1ERC1155Contract.attach(address.Gen1ERC1155);

*/
    if(runApproval) {
        await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,address.PancakeNftERC11155,address.Event, true)
        await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155, address.Gen1ERC1155, address.Event, true)
    }

    const recruitStaker = await EventGen0Deploy.recruitStaker(process.env.OWNER)
    console.log({recruitStaker})
    const recruitPancakeStatus = await EventGen0Deploy.recruitPancakeStatus(legionTokenId)
    console.log({recruitPancakeStatus})
    //const legionsAddress = await EventGen0Deploy.legions()
    //console.log({legionsAddress})

    //const _timeForReward = await EventGen0Deploy._timeForReward()
    //console.log({_timeForReward})

    if(runSetTime){
        //const _timeForReward = await EventGen0Deploy._timeForReward()
        //console.log({_timeForReward})
        await EventGen0Deploy.setTimeForReward(process.env.TIME_FOR_REWARD)
    }
    if(runStake &&  !parseInt(recruitStaker?.tokenId) && !parseInt(recruitPancakeStatus)){
        const responseStake = await EventGen0Deploy.stake(legionTokenId);
        console.log("EventGen0Deploy responseStake",responseStake);

    }
    const _timeForReward = await EventGen0Deploy._timeForReward()
    console.log({_timeForReward})

    if(runClaimReward && parseInt(recruitStaker?.tokenId)){
        const claimDate = new Date((parseInt(recruitStaker?.time) + parseInt(_timeForReward)) * 1000)
        //const canClaim = new Date().getTime() > claimDate.getTime()

        /* const timeDiff =
             (parseInt(recruitStaker?.time) + parseInt(_timeForReward)) * 1000 -
             new Date().getTime();
         console.log({timeDiff})*/
        const canClaim = await EventGen0Deploy.canClaim(recruitStaker?.tokenId)
        console.log({canClaim})
        if(canClaim){
            console.log("can claim.............",canClaim,"claimDate",claimDate,"recruitStaker?.tokenId",recruitStaker?.tokenId)
            console.log("claim start.............")
            const {signature,message} = generateSignature(process.env.OWNER, legionTokenId);
            const responseclaimReward = await EventGen0Deploy.claimReward(recruitStaker?.tokenId,signature);
            console.log("EventGen0Deploy claimReward",responseclaimReward);
        }
    }

    if(runUnStake && parseInt(recruitStaker?.tokenId)){
        //approval
        const updateRecruitStake = await EventGen0Deploy.updateRecruitStake(process.env.OWNER,true,false);
        console.log("updateRecruitStake responseStake",updateRecruitStake);
    }
    if(setUnClaimed && parseInt(recruitStaker?.tokenId)){
        //approval
        const updateRecruitStake = await EventGen0Deploy.updateRecruitStake(process.env.OWNER,false,true);
        console.log("EventGen0Deploy responseStake",updateRecruitStake);
    }
}
main()
