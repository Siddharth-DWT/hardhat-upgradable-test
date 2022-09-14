const {CONTRACT_NAME_MAP, deployProxyContract,generateSignature, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");


async function main(){
    //await deployWithVerifyContract(CONTRACT_NAME_MAP.SignatureChecker,[], true)

    setTimeout(async()=>{
        const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.SignatureChecker);
        const SignatureChecker = ErrandGen0Contract.attach(address.SignatureChecker);
        const {message,signature} = generateSignature(process.env.OWNER)
        console.log("signature--->",signature)


        const res= await SignatureChecker.getSigner(message,signature)
        console.log("res",res);

        const resBool = await  SignatureChecker.checkSignature(message,signature)
        console.log("resBool",resBool);

        const validatorAddress = await  SignatureChecker.validatorAddress()
        console.log("validatorAddress",validatorAddress);
    },10000)



}
main()
