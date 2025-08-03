# ========================
# REP8 - Quick Project Bootstrap (PNPM Version - PowerShell)
# ========================

# 1. GIT & INITIAL PUSH TO GITHUB
echo "# rep-8" | Out-File -FilePath README.md -Encoding UTF8
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/shreyan001/rep-8.git
git push -u origin main

# 2. INSTALL HARDHAT FOR SOLIDITY CONTRACT DEVELOPMENT
pnpm init -y
pnpm add -D hardhat
Write-Host "Please run 'npx hardhat' and choose 'Create a basic sample project'"
pnpm add -D @nomiclabs/hardhat-ethers ethers @openzeppelin/contracts dotenv

# 3. CREATE REP8 SUBSCRIPTION CONTRACT
New-Item -ItemType Directory -Force -Path contracts
@'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IOrderMixin {
    struct Order {
        uint256 salt;
        address makerAsset;
        address takerAsset;
        address maker;
        address receiver;
        address allowedSender;
        uint256 makingAmount;
        uint256 takingAmount;
        uint256 offsets;
        bytes interactions;
    }
}

interface IPreInteraction {
    function preInteraction(
        IOrderMixin.Order calldata order,
        bytes calldata extension,
        bytes32 orderHash,
        address taker,
        uint256 makingAmount,
        uint256 takingAmount,
        uint256 remainingMakingAmount,
        bytes calldata extraData
    ) external view;
}

contract REP8SubscriptionPreInteraction is IPreInteraction {
    mapping(address => bool) public isSubscribed;
    address public immutable owner;

    event Subscribed(address indexed user);

    constructor() {
        owner = msg.sender;
    }

    function subscribe() external {
        require(!isSubscribed[msg.sender], "Already subscribed");
        isSubscribed[msg.sender] = true;
        emit Subscribed(msg.sender);
    }

    function preInteraction(
        IOrderMixin.Order calldata /*order*/,
        bytes calldata /*extension*/,
        bytes32 /*orderHash*/,
        address taker,
        uint256 /*makingAmount*/,
        uint256 /*takingAmount*/,
        uint256 /*remainingMakingAmount*/,
        bytes calldata /*extraData*/
    ) external view override {
        require(isSubscribed[taker], "Not subscribed, cannot fill this order");
    }
}
'@ | Out-File -FilePath contracts/REP8SubscriptionPreInteraction.sol -Encoding UTF8

# 4. HARDHAT CONFIG - ADD CONTRACT DEPLOY/TEST
@'
require('@nomiclabs/hardhat-ethers');
module.exports = {
  solidity: '0.8.23',
  networks: {
    hardhat: {},
  },
};
'@ | Out-File -FilePath hardhat.config.js -Encoding UTF8

# 5. SAMPLE DEPLOY SCRIPT
New-Item -ItemType Directory -Force -Path scripts
@'
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
'@ | Out-File -FilePath scripts/deploy.js -Encoding UTF8

# 6. WRITE A SIMPLE TEST (optional, for confidence)
New-Item -ItemType Directory -Force -Path test
@'
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
'@ | Out-File -FilePath test/rep8.js -Encoding UTF8

# 7. CREATE VITE + REACT FRONTEND
pnpm create vite@latest frontend -- --template react
Set-Location frontend
pnpm install
pnpm add ethers

# 8. CREATE SUBSCRIPTION DEMO COMPONENT
@'
import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

// Replace with your deployed contract address
const CONTRACT_ADDRESS = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
const CONTRACT_ABI = [
  "function subscribe() external",
  "function isSubscribed(address) view returns (bool)",
  "event Subscribed(address indexed user)"
];

function SubscribeDemo() {
  const [account, setAccount] = useState(null);
  const [subscribed, setSubscribed] = useState(false);
  const [status, setStatus] = useState('');

  const connectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
        checkSubscription(accounts[0]);
      } catch (error) {
        setStatus('Error connecting wallet');
      }
    } else {
      setStatus('Please install MetaMask');
    }
  };

  const checkSubscription = async (address) => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, provider);
      const isSubbed = await contract.isSubscribed(address);
      setSubscribed(isSubbed);
    } catch (error) {
      setStatus('Error checking subscription');
    }
  };

  const subscribe = async () => {
    try {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      const tx = await contract.subscribe();
      setStatus('Transaction pending...');
      await tx.wait();
      setStatus('Subscribed successfully!');
      setSubscribed(true);
    } catch (error) {
      setStatus('Error subscribing');
    }
  };

  return (
    <div style={{ padding: '20px', textAlign: 'center' }}>
      <h1>REP8 Subscription Demo</h1>
      {!account
        ? <button onClick={connectWallet}>Connect Wallet</button>
        : (
          <>
            <p>Wallet: {account}</p>
            {subscribed
              ? <p>✅ You are subscribed!</p>
              : <button onClick={subscribe}>Subscribe</button>
            }
            <p>{status}</p>
          </>
        )
      }
    </div>
  );
}

export default SubscribeDemo;
'@ | Out-File -FilePath src/SubscribeDemo.jsx -Encoding UTF8

# 9. UPDATE VITE FRONTEND (src/App.jsx)
@'
import { useState } from 'react'
import reactLogo from './assets/react.svg'
import viteLogo from '/vite.svg'
import './App.css'
import SubscribeDemo from './SubscribeDemo'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <div>
        <a href="https://vitejs.dev" target="_blank">
          <img src={viteLogo} className="logo" alt="Vite logo" />
        </a>
        <a href="https://react.dev" target="_blank">
          <img src={reactLogo} className="logo react" alt="React logo" />
        </a>
      </div>
      <h1>Vite + React</h1>
      <SubscribeDemo />
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>
          Edit <code>src/App.jsx</code> and save to test HMR
        </p>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  )
}

export default App
'@ | Out-File -FilePath src/App.jsx -Encoding UTF8

# 10. FINAL README (Add to project root)
Set-Location ..
@'
# REP8

**REP8 is a permissioned subscription extension for the 1inch Limit Order Protocol.**
Users must subscribe to fill special orders, creating new incentives and use cases for promo, campaign, and DAO liquidity.

## Features
- On-chain subscription 'join' and status tracking
- Solidity contract gated by subscriptions (plug into 1inch via preInteraction)
- Minimal frontend: wallet connect, join, and status display
- Ready to extend with custom rewards, analytics, or campaign logic

## How To Use

### 1. Clone, install, and deploy contract locally (hardhat):
```bash
pnpm install
npx hardhat node
npx hardhat run scripts/deploy.js --network localhost
```

### 2. Update CONTRACT_ADDRESS in frontend/src/SubscribeDemo.jsx.

### 3. Start frontend:
```bash
cd frontend
pnpm run dev
```

### 4. Open browser, connect wallet, subscribe, and see status.

## Development

### Run tests:
```bash
npx hardhat test
```

### Deploy to other networks:
Update `hardhat.config.js` with network configuration and run:
```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

## Architecture

- **Smart Contract**: `REP8SubscriptionPreInteraction.sol` - Manages subscriptions and validates orders
- **Frontend**: React + Vite app with wallet integration
- **Deployment**: Hardhat for contract deployment and testing

'@ | Out-File -FilePath README.md -Encoding UTF8

# 11. PUSH TO GITHUB
git add .
git commit -m "Initial working REP8 subscription contract, deploy script, and demo frontend with pnpm"
git push origin main

Write-Host "====== REP8 SETUP COMPLETE ======" -ForegroundColor Green
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run: npx hardhat node (in one terminal)" -ForegroundColor Cyan
Write-Host "2. Run: npx hardhat run scripts/deploy.js --network localhost" -ForegroundColor Cyan
Write-Host "3. Update CONTRACT_ADDRESS in frontend/src/SubscribeDemo.jsx" -ForegroundColor Cyan
Write-Host "4. Run: cd frontend && pnpm run dev" -ForegroundColor Cyan
Write-Host "5. Open browser and test the demo!" -ForegroundColor Cyan