const {CONTRACT_NAME_MAP, approveContract,generateSignature, deployWithVerifyContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");

const deploy=false;
const runMethod = true, runApproval=false;

async function main(){

    const {IngredientsERC11155,SignatureChecker, IngredientDrop} = address;
    if(deploy){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.IngredientDrop,[IngredientsERC11155,SignatureChecker])
    }
    if(runApproval){
        await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155,IngredientsERC11155,IngredientDrop, true,'IngredientDrop')

    }
    if(runMethod){
        const IngredientDropContract = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientDrop);
        const DeployedIngredientDrop = IngredientDropContract.attach(address.IngredientDrop);

        const Ingredient = await ethers.getContractFactory(CONTRACT_NAME_MAP.IngredientsERC11155);
        const IngredientContract = Ingredient.attach(address.IngredientsERC11155);

        const tokenBefore = await IngredientContract.getWalletToken()
        console.log({tokenBefore})
        const nonOfClaim = 4;
        //const validatorAddress = await  SignatureChecker.validatorAddress()
        const {message,signature} = generateSignature(process.env.OWNER,nonOfClaim)
        //console.log("signature--->",signature)
        const claimResponse  = await DeployedIngredientDrop.claim(nonOfClaim,signature)
        console.log("claimResponse",claimResponse);
        const tokenAfter = await IngredientContract.getWalletToken()
        console.log({tokenAfter})
    }
}
main()
