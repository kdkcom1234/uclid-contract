const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers } = require("hardhat");

module.exports = buildModule("ProbeNodeModule", (m) => {
  const deployer = m.getAccount(0);
  console.log("=========deployer=======");
  console.log(deployer);

  const token = m.contract(
    "ProbeNode", // contract name
    [
      deployer,
      "https://kdkcom1234.github.io",
      "/uclid-probe-node-meta/probe-meta.json",
      ethers.parseEther("0.001").toString(),
    ], // constructor args array
    {} // option ({ value: [sending ETH] })
  );

  return { token };
});
