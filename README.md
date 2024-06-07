## compile and test

```shell
npx hardhat compile
npx hardhat test ./test/ProbeNode.js
```

## run local nodes and deploy

```shell
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/NFTTrial.js --network localhost
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
  "contracts/NFTTrial.sol:NFTTrial",
  "0x5FbDB2315678afecb367f032d93F642f64180aa3"
);

// owner
const owner = await token.owner();
console.log(owner.toString());

// mint
// await token.mint("[trait-sequence]")
const txn = await token.mint("0-0-0-0-0-0-0-0-0-0-0-0-0");
const receipt = await txn.wait();

// totalSupply
const totalSupply = await token.totalSupply();

// get token full uri from address
const uri = await token.tokenURIByAddress(
  "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
);

// fetch meta
const res = await fetch(uri);
const meta = await res.json();
console.log(meta);
console.log(meta.image);
```

## deploy to test network

```shell
npx hardhat ignition deploy ./ignition/modules/NFTTrial.js --network amoy
# 0xF684e90593190D5A4b50367231ba1899A77128ac
# https://www.oklink.com/ko/amoy/address/0xF684e90593190D5A4b50367231ba1899A77128ac
```
