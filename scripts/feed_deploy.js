const {CONTRACT_NAME_MAP,deployProxyContract,deployWithVerifyContract} = require("../utils/common");
const address= require("../address.json")
const deployConst = true;
async function main() {
    const {PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker} = address
    if(!CommonConstGen0){
        await deployWithVerifyContract(CONTRACT_NAME_MAP.CommonConstGen0,[])
    }
    await deployProxyContract(CONTRACT_NAME_MAP.Feed,[PancakeNftERC11155,IngredientsERC11155,BossCardERC1155,CommonConstGen0,SignatureChecker])
}
main();

const hre = require("hardhat");
const { upgrades } = require("hardhat");

async function main() {
  const Lock = await hre.ethers.getContractFactory("Feed");
  const lock = await upgrades.deployProxy(Lock, [addr1, addr2, addr3, addr4, addr5]);
  console.log(`Feed contract de`)

  await lock.deployed();

  console.log(
    `Lock deployed to ${lock.address}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});




async function deployProxyContract(contractName, params){
    console.log(`Deploying ${contractName}...`);
    const Contract = await ethers.getContractFactory(contractName);
    const deployedContract = await upgrades.deployProxy(Contract,[...params]);
    await deployedContract.deployTransaction.wait(10);
    console.log(deployedContract.address,` ${contractName}(proxy) address`)
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(deployedContract.address)
    console.log(implementationAddress," getImplementationAddress")
    console.log(await upgrades.erc1967.getAdminAddress(deployedContract.address)," getAdminAddress")

    await writeAddress(contractName,deployedContract.address)
    await writeAddress(contractName+"_IMP",implementationAddress)

    //console.log(`Verifying ${contractName} on ${process.env.DEPLOY_ENV}...`);

}