require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const dotenv = require("dotenv");
dotenv.config();

const forking = {
  url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API}`,
  // blockNumber: 13502337,
  blockNumber: 13550715,
};
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking,
      chainId: 1337,
      // mining: {
      //   auto: false,
      //   interval: 200,
      // },
    },
    ropsten: {
      url: `https://eth-ropsten.alchemyapi.io/v2/${process.env.ALCHEMY_API}`,
      accounts: [`0x${process.env.ROPSTEN_PRIVATE_KEY}`],
    },
  },

  solidity: {
    version: "0.8.6",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  mocha: {
    timeout: 3000000000,
  },
};
