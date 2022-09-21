const {CONTRACT_NAME_MAP, verifyProxyContract, approveContract} = require("../utils/common")
const address= require("../address.json")
const {ethers} = require("hardhat");
async function main(){
    const {PowerPlinsGen0ERC721,IngredientsERC11155,BossCardERC1155,PancakeNftERC11155, Gen1ERC1155, SignatureChecker, ErrandGen0,ErrandGen1, Cook, Shrine} = address

    //ERRAND
    await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, IngredientsERC11155, ErrandGen0, true,"ErrandGen1")
    await approveContract(CONTRACT_NAME_MAP.IngredientsERC11155, IngredientsERC11155, ErrandGen1, true,"ErrandGen0")

    //COOK
    await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,PancakeNftERC11155,Cook, true,'Cook')

    //SHRINE
    await approveContract(CONTRACT_NAME_MAP.PancakeNftERC11155,PancakeNftERC11155,Shrine, true,'Shrine')
    await approveContract(CONTRACT_NAME_MAP.Gen1ERC1155,Gen1ERC1155,Shrine, true,'Shrine')

    const ErrandGen0Contract = await ethers.getContractFactory(CONTRACT_NAME_MAP.SignatureChecker);
    const DeployedSignatureChecker = ErrandGen0Contract.attach(SignatureChecker);

    console.log("Updating ValidatorAddress....")
    await DeployedSignatureChecker.setValidatorAddress(process.env.SIGNATURE_VALIDATOR)
    console.log(`address ${process.env.SIGNATURE_VALIDATOR} updated`)



}
main()
