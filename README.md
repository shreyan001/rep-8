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

