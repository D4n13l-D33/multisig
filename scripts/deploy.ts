import { ethers } from "hardhat";

async function main() {
  const signers = ["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB"]
  const quorum = 3;

  const multisig = await ethers.deployContract("Multisig", [signers, quorum]);

  await multisig.waitForDeployment();

  console.log(
    `Multisig contract deployed to ${multisig.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
