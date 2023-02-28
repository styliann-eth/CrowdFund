const { ethers } = require('hardhat');
require('@nomiclabs/hardhat-ethers');

async function main() {
  const [owner, signer2] = await ethers.getSigners();
  // const provider = new ethers.providers.JsonRpcProvider();
  // const wallet = new ethers.Wallet(
  //   'ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
  //   provider
  // );

  // const owner = await wallet.getAddress();

  Usdt = await ethers.getContractFactory('USDT', owner);
  usdt = await Usdt.deploy();

  Crowdsale = await ethers.getContractFactory('Crowdsale', owner);
  crowdSale = await Crowdsale.deploy(2, owner.address, usdt.address);

  await usdt
    .connect(owner)
    .mint(crowdSale.address, ethers.utils.parseEther('10000'));

  console.log('Crowdsale:', crowdSale.address);
  console.log('USDT:', usdt.address);
}

// npx hardhat run --network localhost scripts/deploy.js

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
