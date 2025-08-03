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
              ? <p>âœ… You are subscribed!</p>
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
