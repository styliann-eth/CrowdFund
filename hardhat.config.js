/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.9',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  // defaultNetwork: 'hardhat',
  // networks: {
  //   hardhat: {
  //     chainId: 1337,
  //     allowUnlimitedContractSize: true,
  //   },
  // },
};
