
const { ethers } = require("hardhat");

async function main() {
  console.log("Starting Decentralized Skill Verification Oracle deployment on Core Testnet 2...");
  
  // Get the deployer account
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  // Check deployer balance
  const balance = await deployer.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "CORE");
  
  if (balance < ethers.parseEther("0.1")) {
    console.warn("⚠️  Low balance! Make sure you have enough CORE tokens for deployment and gas fees.");
  }
  
  try {
    // Deploy the Project contract
    console.log("\n📦 Deploying Skill Verification Oracle contract...");
    const Project = await ethers.getContractFactory("Project");
    const project = await Project.deploy();
    
    // Wait for deployment confirmation
    await project.waitForDeployment();
    const contractAddress = await project.getAddress();
    
    console.log("✅ Skill Verification Oracle deployed successfully!");
    console.log("📍 Contract Address:", contractAddress);
    console.log("🔗 Network: Core Testnet 2");
    console.log("⛽ Deployer:", deployer.address);
    
    // Display contract details
    console.log("\n📋 Contract Details:");
    console.log("- Name: SkillCertificate");
    console.log("- Symbol: SKILL");
    console.log("- Minimum Stake: 0.01 CORE");
    console.log("- Verification Fee: 0.005 CORE");
    console.log("- Verifier Stake: 0.05 CORE");
    console.log("- Verification Deadline: 7 days");
    console.log("- Required Verifiers: 3");
    console.log("- Minimum Score: 70/100");
    
    // Verify deployment by calling view functions
    try {
      const totalRequests = await project.getTotalRequests();
      const totalCertificates = await project.getTotalCertificates();
      console.log("- Total Requests:", totalRequests.toString());
      console.log("- Total Certificates:", totalCertificates.toString());
      console.log("✅ Contract verification successful!");
    } catch (error) {
      console.log("⚠️  Contract verification failed:", error.message);
    }
    
    // Display skill categories
    console.log("\n🎯 Available Skill Categories:");
    console.log("0. Programming");
    console.log("1. Design");
    console.log("2. Marketing");
    console.log("3. Finance");
    console.log("4. Management");
    console.log("5. DataScience");
    console.log("6. Blockchain");
    console.log("7. Other");
    
    console.log("\n🎉 Deployment completed successfully!");
    console.log("\n📝 Next Steps:");
    console.log("1. Register as a verifier with expertise areas");
    console.log("2. Submit skill verification requests");
    console.log("3. Participate in peer assessment process");
    console.log("4. Earn reputation and skill certificates");
    console.log("5. Build your decentralized professional profile");
    
    console.log("\n💡 Usage Examples:");
    console.log("Register as Verifier:");
    console.log("  registerVerifier([0, 6]) // Programming & Blockchain");
    console.log("  Value: 0.05 CORE");
    
    console.log("\nSubmit Skill Request:");
    console.log("  submitSkillRequest(0, 'Solidity Development', 'desc', 'challenge')");
    console.log("  Value: 0.015 CORE (0.01 stake + 0.005 fee)");
    
    console.log("\nSubmit Verification:");
    console.log("  submitVerification(requestId, 85, 'Excellent work!')");
    
    // Save deployment info to a file
    const deploymentInfo = {
      network: "Core Testnet 2",
      contractAddress: contractAddress,
      deployerAddress: deployer.address,
      deploymentTime: new Date().toISOString(),
      blockNumber: await deployer.provider.getBlockNumber(),
      transactionHash: project.deploymentTransaction().hash,
      contractDetails: {
        name: "SkillCertificate",
        symbol: "SKILL",
        minStake: "0.01 CORE",
        verificationFee: "0.005 CORE",
        verifierStake: "0.05 CORE",
        verificationDeadline: "7 days",
        requiredVerifiers: 3,
        minimumScore: 70
      },
      skillCategories: [
        "Programming",
        "Design", 
        "Marketing",
        "Finance",
        "Management",
        "DataScience",
        "Blockchain",
        "Other"
      ]
    };
    
    const fs = require('fs');
    fs.writeFileSync(
      'deployment-info.json', 
      JSON.stringify(deploymentInfo, null, 2)
    );
    console.log("💾 Deployment info saved to deployment-info.json");
    
  } catch (error) {
    console.error("❌ Deployment failed:", error.message);
    
    if (error.message.includes("insufficient funds")) {
      console.log("\n💡 Solutions:");
      console.log("- Get test CORE tokens from the faucet");
      console.log("- Check your wallet balance");
      console.log("- Reduce gas price in hardhat.config.js");
    } else if (error.message.includes("nonce")) {
      console.log("\n💡 Solution: Reset your account nonce in MetaMask");
    } else if (error.message.includes("gas")) {
      console.log("\n💡 Solution: Increase gas limit or reduce contract complexity");
    }
    
    process.exit(1);
  }
}

// Handle errors
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Unexpected error:", error);
    process.exit(1);
  });
