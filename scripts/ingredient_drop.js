const {CONTRACT_NAME_MAP, approveContract,generateSignature, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const deploy=false;
const runMethod = true, runApproval=false, updateValidator=false;

async function main(){

    const {IngredientsERC11155,SignatureChecker, IngredientDrop} = address;
    const SignatureCheckerContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.SignatureChecker);
    const DeployedSignatureCheckerContract = SignatureCheckerContract.attach(address.SignatureChecker);

    const IngredientsERC11155Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
    const DeployedIngredientsERC11155 = IngredientsERC11155Contract.attach(address.IngredientsERC11155);

    if(deploy){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.IngredientDrop,[IngredientsERC11155,SignatureChecker])
    }
    if(runApproval){
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,IngredientsERC11155,IngredientDrop, true,'IngredientDrop')

    }
    if(updateValidator){
        await DeployedSignatureCheckerContract.setValidatorAddress(process.env.SIGNATURE_VALIDATOR);
    }
    if(runMethod){
        const IngredientDropContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientDrop);
        const DeployedIngredientDrop = IngredientDropContract.attach(address.IngredientDrop);

        const Ingredient = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
        const IngredientContract = Ingredient.attach(address.IngredientsERC11155);

        const tokenBefore = await IngredientContract.getWalletToken()
        //console.log({tokenBefore})
        const nonOfClaim = 4;
        const validatorAddress = await  DeployedSignatureCheckerContract.validatorAddress()
        console.log("validatorAddress",validatorAddress)

        const {message,signature} = generateSignature(process.env.OWNER,nonOfClaim)
        console.log("message",message);
        console.log("signature--->",signature)

        const getSigner = await  DeployedSignatureCheckerContract.getSigner(message,signature)
        console.log("getSigner",getSigner)

        const checkSignature = await  DeployedSignatureCheckerContract.checkSignature(message,signature)
        console.log("checkSignature",checkSignature)


        const isMintApprovedForAll = await DeployedIngredientsERC11155.isMintApprovedForAll(IngredientDrop)
        console.log({isMintApprovedForAll})
        /*const airdrop  = await DeployedIngredientDrop.airdrops(process.env.OWNER);
        console.log("airdrop--->",airdrop)*/

        const claimResponse  = await DeployedIngredientDrop.claim(nonOfClaim,signature)
        console.log("claimResponse",claimResponse);

        const tokenAfter = await IngredientContract.getWalletToken()
        console.log({tokenAfter})
    }
}
main()
