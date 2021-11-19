const hre = require("hardhat");

async function main() {
  const Fishbank = await ethers.getContractFactory("Fishbank");
  const fishbank = await Fishbank.deploy(
    "0xb2f43262fc23d253538ca5f7b4890f89f0ee95d9", // Treasury
    "0xbCc10bC2a24b07b598D7794FecFDb42B48a5c435" // Token
  );
  await fishbank.deployed();

  console.log("Deployed fishbank to " + fishbank.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
