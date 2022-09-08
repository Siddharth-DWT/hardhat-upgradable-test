require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require('@openzeppelin/hardhat-upgrades');

// The next line is part of the sample project, you don't need it in your
// project. It imports a Hardhat task definition, that can be used for
// testing the frontend.
require("./tasks/faucet");

/** @type import('hardhat/config').HardhatUserConfig */

const Private_Key = "08fcf0243a45b2a3957dbb995c01f594e7b6752517bc92cf314ee1770d370218"

module.exports = {
  solidity: "0.8.11",
  networks: {
    ropsten: {
      //chainId: 1337,// We set 1337 to make interacting with MetaMask simpler
      url: `https://ropsten.infura.io/v3/f0a04b531d2c427d803c825ea7349796`,
  		accounts: [`0x${Private_Key}`]
    },
  }
};
