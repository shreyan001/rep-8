const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("REP8SubscriptionPreInteraction", function () {
  it("Should allow subscription and check status", async function () {
    const REP8 = await ethers.getContractFactory("REP8SubscriptionPreInteraction");
    const rep8 = await REP8.deploy();
    await rep8.deployed();

    const [owner, addr1] = await ethers.getSigners();
    
    // Check initial state
    expect(await rep8.isSubscribed(addr1.address)).to.equal(false);
    
    // Subscribe
    await rep8.connect(addr1).subscribe();
    expect(await rep8.isSubscribed(addr1.address)).to.equal(true);
  });
});
