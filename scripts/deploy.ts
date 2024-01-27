import { ethers } from "hardhat";

async function main() {
  const deployedContract = await ethers.deployContract("BudgetProof", [/* MASTER PUBLIC KEY */]);

  await deployedContract.waitForDeployment();

  await (await deployedContract.createBudget("Гумманитарная помощь", 10_000_000_000)).wait();

  const volunteerId = await (await deployedContract.createVolunteer(0, "volunteer name", 5_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();

  await (await deployedContract.createAllocation(0, 0, "self-allocation 0", 1_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();
  await (await deployedContract.createAllocation(0, 0, "self-allocation 1", 1_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();
  await (await deployedContract.createAllocation(0, 0, "self-allocation 2", 1_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();
  await (await deployedContract.createAllocation(0, 0, "self-allocation 3", 1_000_000, "0xb794f5ea0ba39494ce839613fffba74279579268")).wait();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
