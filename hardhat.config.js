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
    arbitrum_gorli: {
      url: `https://goerli-rollup.arbitrum.io/rpc/`,
      accounts: [process.env.PRI_KEY]
    }
  },
  etherscan: {
    apiKey: process.env.ARBISCAN_API_KEY
  }
  // customChains: [
  //   {
  //     network: "arbitrum_gorli",
  //     chainId: 421613,
  //     urls: {
  //       apiURL: "https://api-rinkeby.etherscan.io/api",
  //       browserURL: "https://goerli-rollup-explorer.arbitrum.io"
  //     }
  //   }
  // ]
};



