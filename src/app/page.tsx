'use client';
import React, { useState } from 'react';
import { useModal } from 'connectkit';
import { useAccount, useDisconnect } from 'wagmi';
import { ethers } from 'ethers';
import contractABI from './abi.json';

const contractAddress = "0x670aa2cfea6fba456bc0e5cd288bdec8cd0acbf4";
const provider = new ethers.JsonRpcProvider('https://eth-goerli.g.alchemy.com/v2/Hi0PXrzRbpOJUDt00u5M5402QyDKrqcz');
const contract = new ethers.Contract(contractAddress, contractABI, provider);
const submitNumbers = async () => {
  try {
    await contract.stake();
  } catch (error) {
    console.error("Error loading data from the contract:", error);
    alert("Failed to load data from the contract.");
  }
};

const winnings = async () => {
  try {
    await contract.claimWinnings();
  } catch (error) {
    console.error("Error loading data from the contract:", error);
    alert("Failed to load data from the contract.");
  }
};

export default function Home() {
  const { isConnected, address } = useAccount();
  const { setOpen } = useModal();
  const { disconnect } = useDisconnect();
  var potSize: number = 0;

  return (
    <div className="lottery-home">
      {!isConnected && (
        <div>
          <h1>Connect to your wallet to participate!</h1>
          <h1>Current pot size: ${potSize}</h1>
          <button className="connect-button" onClick={() => setOpen(true)}>
            Connect Wallet
          </button>
        </div>
      )}

      {isConnected && (
          <div>
            <h1>🎱 Lottery Game 🎱</h1>
            <p>Choose your lucky numbers:</p>
            <div className="number-buttons">
              {Array.from({ length: 50 }, (_, index) => (
                <button key={index + 1}>{index + 1}</button>
              ))}
            </div>
            <button className="action-button" onClick={submitNumbers} >Submit Numbers</button>
            <div>
              <h2>Your Selected Numbers:</h2>
            </div>
            <button className="action-button" onClick={winnings}>Get Rewards</button>


            <div className="wallet-info">
              <p>Connected Wallet: {address}</p>
              <button className="action-button" onClick={() => disconnect()}>
                Disconnect
              </button>
            </div>
          </div>
      )}
    </div>
  );
}
