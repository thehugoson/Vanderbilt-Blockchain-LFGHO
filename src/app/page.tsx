'use client'
import React, { useState, useEffect } from 'react';
import { useModal } from 'connectkit';
import { useAccount, useDisconnect } from 'wagmi';

export default function Home() {
  const { isConnected, address, isConnecting } = useAccount();
  const { setOpen } = useModal();
  const { disconnect } = useDisconnect();
  const [countdown, setCountdown] = useState(300); // set later from backend
  const [timer, setTimer] = useState<NodeJS.Timer | null>(null);
  var potSize: number = 0;

  useEffect(() => {
    if (countdown > 0) {
      const newTimer = setInterval(() => {
        setCountdown((prevCountdown) => prevCountdown - 1);
      }, 1000);

      setTimer(newTimer);
    }

    return () => {
      if (timer) {
        clearInterval(timer);
      }
    };
  }, [countdown, timer]);

  function formatTime(seconds: number) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${String(minutes).padStart(2, '0')}:${String(remainingSeconds).padStart(2, '0')}`;
  }

  if (isConnecting) return <div className="lottery-home">
      <div className="lottery-home">
          <h1>Connect to your wallet to participate!</h1>
          <h1>Current pot size: ${potSize}</h1>
          <button className="connect-button" onClick={() => setOpen(true)}>
            Connect Wallet
          </button>
        </div>
     </div>;

  return (
    <div>
      {!isConnected && (
        <div className="lottery-home">
          <h1>Connect to your wallet to participate!</h1>
          <h1>Current pot size: ${potSize}</h1>
          <button className="connect-button" onClick={() => setOpen(true)}>
            Connect Wallet
          </button>
        </div>
      )}

      {isConnected && (
          <div className="lottery-page">
            <h1>🎱 Lottery Game 🎱</h1>
            <p>Choose your lucky numbers:</p>
            <div className="number-buttons">
              {Array.from({ length: 50 }, (_, index) => (
                <button key={index + 1}>{index + 1}</button>
              ))}
            </div>
            <button className="action-button">Submit Numbers</button>
            <div>
              <h2>Your Selected Numbers:</h2>
            </div>
            <button className="action-button">Draw Lottery Numbers</button>
            <div>
              <h2>Results:</h2>
            </div>

            <div className="wallet-info">
              <p>Connected Wallet: {address}</p>
              <button className="action-button" onClick={() => disconnect()}>
                Disconnect
              </button>
            </div>
            <div>
              <h3>Countdown: {formatTime(countdown)}</h3>
            </div>
          </div>
      )}
    </div>
  );
}
