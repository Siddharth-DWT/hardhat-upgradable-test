require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

require('dotenv').config();


module.exports = {
  solidity: "0.8.10",
  settings: {
    optimizer: {
      enabled: true,
      runs: 1000,
    },
  },
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRI_KEY],
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRI_KEY]
    },
    arbitrum_rinkeby: {
      url: `https://rinkeby.arbitrum.io/rpc`,
      accounts: [process.env.PRI_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.ARBISCAN_API_KEY,
  },
};



