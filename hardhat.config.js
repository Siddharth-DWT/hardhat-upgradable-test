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
    arbitrum_rinkeby: {
      url: `https://rinkeby.arbitrum.io/rpc`,
      accounts: [process.env.PRI_KEY]
    },
    arbitrum_gorli: {
      url: `https://goerli-rollup.arbitrum.io/rpc/`,
      accounts: [process.env.PRI_KEY]
    },
    arbitrumOne: {
      url: `https://arb1.arbitrum.io/rpc`,
      accounts: [process.env.PRI_KEY]
    }
  },
  etherscan: {
    apiKey: {
      arbitrumOne: process.env.ARBISCAN_API_KEY,
      arbitrumTestnet: process.env.ARBISCAN_API_KEY
    }
  },
  customChains: [
    {
      network: "arbitrum_gorli",
      chainId: 421613,
      urls: {
        apiURL: "https://api-rinkeby.etherscan.io/api",
        browserURL: "https://goerli-rollup-explorer.arbitrum.io"
      }
    }
  ]
};


