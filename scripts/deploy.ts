import { ethers } from "hardhat";

async function main() {
  const deployedContract = await ethers.deployContract("BudgetProof", [/* MASTER PUBLIC KEY */]);

  await deployedContract.waitForDeployment();

  console.log(await deployedContract.getAddress())

  // rec0: b4d297022035d632951d1cd2fc3306a4598ec311a769137ccf42db9fedbc9e5c 0x492646f7a214B1632399a24e39d8c7c1903ede3F
  // rec1: fa55889041b2c00b6855c33a80050996beb79ebd5e5e40b255939af340501d62 0x05E5fDA76A079966682564d097D593F3009dE9aA

  // vol0: f6d0d0005655112683b7e212382a97bdc029d373dc273e80b1b672b0373645c3 0x38B47666BbcBc81559604FF30946F28C269144D6

  await (await deployedContract.createCampaign("Гумманитарная помощь", 10_000_000_000, "UZS")).wait();
  await (await deployedContract.createCampaign("Гумманитарная помощь 2", 100_000_000, "USD")).wait();

  await (await deployedContract.createAllocation(0, "Qudratov Shaxzod", "0x492646f7a214B1632399a24e39d8c7c1903ede3F", 10_000_000, "0x38B47666BbcBc81559604FF30946F28C269144D6", "Rasuljon Qodiriy")).wait();

  // console.log(await deployedContract.budgetCounter());
  console.log(await deployedContract.getBudgets());
  console.log(await deployedContract.getBudget(0));

  // const volunteerId = await (await deployedContract.createVolunteer(0, "volunteer name", 5_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();

  console.log(await deployedContract.getAllocations(0));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
