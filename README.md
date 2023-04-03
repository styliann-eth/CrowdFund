## :whale: Dewhale.capital Private Rounds contract :whale:

### Deployments

- BSC Testnet: https://thirdweb.com/binance-testnet/0xd8b15A9464b183A7ca2923cb4d9510651F10aA42
- BNB Chain Mainnet: -
- Arbitrum: -
- Polygon: -

## Getting started

Clone the repository:

```bash
git clone https://github.com/styliann-eth/private-rounds.git && cd private-rounds
```

Install all required node.js modules:

```bash
yarn
```

Take a look at the code in:

- `contracts/PrivateGroupFactory.sol`
- `contracts/PrivateRounds.sol`

## Building the project

After any changes to the contract, run:

```bash
yarn build
```

to compile your contracts. This will also detect the [Contracts Extensions Docs](https://portal.thirdweb.com/contractkit) detected on your contract.

## Deploying Contracts

When you're ready to deploy your contracts, just run one of the following command to deploy you're contracts:

```bash
yarn deploy
```

From the root /private-rounds folder, use the following to test the subgraph:

```bash
node subgraph/sample-queries/index.js
```
