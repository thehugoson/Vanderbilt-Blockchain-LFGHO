'use client'
import { WagmiConfig, createConfig } from "wagmi";
import { ConnectKitProvider, getDefaultConfig } from "connectkit";
import { ReactNode } from "react";


const config = createConfig(
  getDefaultConfig({
    // Required API Keys
    alchemyId: "",
    walletConnectProjectId: "036041c36e801bbca9ae2649ff644509", //video said it should be ok to push api key

    // Required
    appName: "Your App Name",

    // Optional
    appDescription: "Your App Description",
    appUrl: "https://family.co",
    appIcon: "https://family.co/logo.png",
  }),
);

export const ConnectkitProvider = ({ children }: { children: ReactNode }) => {
    return (
    <WagmiConfig config={config}>
      <ConnectKitProvider
        theme="retro"
      >
        { children }
      </ConnectKitProvider>
    </WagmiConfig>
  );
};
