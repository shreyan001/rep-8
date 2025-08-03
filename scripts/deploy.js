const { ethers } = require("hardhat");

async function main() {
  const REP8 = await ethers.getContractFactory("REP8SubscriptionPreInteraction");
  const rep8 = await REP8.deploy();
  await rep8.deployed();
  console.log("REP8 deployed to:", rep8.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => { console.error(error); process.exit(1); });
