import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
    },
    externalhardhat: {
      url: "http://localhost:8545",
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"]
    },
    prod: {
      url: "https://rpc.budgetproof.uz",
      accounts: ["0x51116ca2696a8a93f73d22a55a8865f999d723996effdcece8f72e85f9ca61bf"]
    },
  }
};

export default config;
