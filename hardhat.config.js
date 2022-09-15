require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

require('dotenv').config();

module.exports = {
  solidity: "0.8.9",
  settings: {
    optimizer: {
      enabled: true,
      runs: 200,
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
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [process.env.PRI_KEY]
    },
    arbitrum_rinkeby: {
      url: `https://rinkeby.arbitrum.io/rpc`,
      accounts: [process.env.PRI_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.GOERLISCAN_API_KEY,
  },
  /*etherscan: {
    apiKey: {
      rinkeby:process.env.ARBISCAN_API_KEY,
    }
  }*/
};



