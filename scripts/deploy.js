async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);
  
    const RockPaperScissors = await ethers.getContractFactory("RockPaperScissors");
    const rps = await RockPaperScissors.deploy("0x55173322BC3eFEb6AcAB65dD3bFA17AD85d1BA30", { value: ethers.utils.parseEther("0.01") });
  
    await rps.deployed();
  
    console.log("RockPaperScissors deployed to:", rps.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });