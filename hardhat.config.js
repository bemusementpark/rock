require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: "0.8.20",
  networks: {
    rskTestnet: {
      url: "https://public-node.testnet.rsk.co",
      accounts: [`0x{env.PRIVATE_KEY}`], // Use your private key
      chainId: 31,
      gasPrice: 1000000000
    }
  }
};
