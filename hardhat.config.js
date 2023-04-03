/** @type import('hardhat/config').HardhatUserConfig */

require('@nomiclabs/hardhat-etherscan');

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
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 97,
      allowUnlimitedContractSize: true,
    },
    bscTestnet: {
      url: 'https://rpc.ankr.com/bsc_testnet_chapel',
      chainId: 97,
      allowUnlimitedContractSize: true,
    },
  },
  etherscan: {
    apiKey: 'MDWSE9W9DI3IIZSTK698PZQG6M11QVUU6R',
  },
};
