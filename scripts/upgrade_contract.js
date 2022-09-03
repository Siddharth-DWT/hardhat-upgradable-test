const { ethers, upgrades } = require("hardhat");

const PROXY = "0xbf4B75D8F5f5F0Fc49bCed26CE41B9f1C7aF4fe6";

async function main() {
    const CalculatorV2 = await ethers.getContractFactory("CalculatorV2");
    console.log("Upgrading Calculator...");
    await upgrades.upgradeProxy(PROXY, CalculatorV2);
    console.log("Calculator upgraded");
}

main();
