## compile and test

```shell
npx hardhat compile
npx hardhat test ./test/ProbeNode.js
```

## run local nodes and deploy

```shell
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/ProbeNode.js --network localhost
# 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

## run hardhat console on local network

```shell
npx hardhat console --network localhost
```

## test using hardhat console

```js
// >
// create object of token contract
const token = await ethers.getContractAt(
  "contracts/ProbeNode.sol:ProbeNode",
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);

// owner
const owner = await token.owner();
console.log(owner.toString());

// mint
// await token.mint("uclid1....address", {value: parseEther("0.001") })
const { ethers } = require("hardhat");
const txn = await token.mint("uclid13hpygej3jglqfeuzs8laurlaak4tmrrgf9myny", {
  value: ethers.parseEther("0.001").toString(),
});
const receipt = await txn.wait();

// get token uri
const uri = await token.tokenURI(1);

// fetch meta
const res = await fetch(uri);
const meta = await res.json();
console.log(meta);
console.log(meta.image);

// totalSupply
const totalSupply = await token.totalSupply();

// total balance of contract
const balance = await ethers.provider.getBalance(
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);

// withdraw balance of contract
const ProbeNode = await ethers.getContractFactory("ProbeNode");
const probeNode = await ProbeNode.attach(
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);
const [owner] = await ethers.getSigners();
const tx = await probeNode
  .connect(owner)
  .withdraw(
    "0x70997970C51812dc3A010C7d01b50e0d17dc79C8",
    ethers.parseEther("0.003").toString()
  );
const receipt = await tx.wait();
console.log(receipt);

const balance1 = await ethers.provider.getBalance(
  "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
);
console.log(balance);
```

## deploy to test network

```shell
npx hardhat ignition deploy ./ignition/modules/ProbeNode.js --network amoy
# 0x37300F3adbB637FE05561e589eA9AD832ed80539
# https://www.oklink.com/ko/amoy/address/0x37300F3adbB637FE05561e589eA9AD832ed80539
```
