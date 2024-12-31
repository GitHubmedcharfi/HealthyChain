const { ethers } = require("hardhat");

async function main() {
  // Get the deployer's signer account
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  // Fetch balance
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account Balance (ETH):", ethers.utils.formatEther(balance));

  // Deploy the contract
  const Agent = await ethers.getContractFactory("Agent");
  const agent = await Agent.deploy();

  console.log("Agent contract deployed at:", agent.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error during deployment:", error);
    process.exit(1);
  });
