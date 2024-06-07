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

// totalSupply
const totalSupply = await token.totalSupply();

// total balance of contract
const balance = await ethers.provider.getBalance(
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);

// get token uri
const uri = await token.tokenURI(1);

// fetch meta
const res = await fetch(uri);
const meta = await res.json();
console.log(meta);
console.log(meta.image);
```

## deploy to test network

```shell
npx hardhat ignition deploy ./ignition/modules/ProbeNode.js --network amoy
# 0x79000DB323bd105dff47e1dd4b706305292Ee4c4
# https://www.oklink.com/ko/amoy/address/0x79000DB323bd105dff47e1dd4b706305292Ee4c4
```
