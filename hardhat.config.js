require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");

require('dotenv').config();

const { POLYGON_MUMBAI_RPC_PROVIDER, PRI_KEY, POLYGONSCAN_API_KEY } = process.env;

module.exports = {
        solidity: "0.8.4",
        defaultNetwork: "matic",
        networks: {
            hardhat: {},
            matic: {
               url: POLYGON_MUMBAI_RPC_PROVIDER,
               accounts: [`0x${PRI_KEY}`],
               gas: 2100000,
               gasPrice: 8000000000
           }
        },
        etherscan: {
           apiKey: POLYGONSCAN_API_KEY,
        }
};


