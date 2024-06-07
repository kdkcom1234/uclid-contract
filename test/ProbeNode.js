const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ProbeNode", function () {
  let ProbeNode;
  let probeNode;
  let owner;
  let addr1;
  let addr2;
  const baseURI = "https://example.com/";
  const metaURI = "metadata.json";
  const mintingFee = ethers.parseEther("0.001");

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();
    ProbeNode = await ethers.getContractFactory("ProbeNode");
    probeNode = await ProbeNode.deploy(
      owner.address,
      baseURI,
      metaURI,
      mintingFee
    );
    await probeNode.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await probeNode.owner()).to.equal(owner.address);
    });

    it("Should set the right baseURI and metaURI", async function () {
      await probeNode.connect(addr1).mint("uclid1Addr", { value: mintingFee });
      expect(await probeNode.baseURI()).to.equal(baseURI);
      expect(await probeNode.tokenURI(1)).to.equal(baseURI + metaURI);
    });

    it("Should set the right minting fee", async function () {
      expect(await probeNode.mintingFee()).to.equal(mintingFee);
    });
  });

  describe("Minting", function () {
    it("Should mint a token and assign it to addr1", async function () {
      await probeNode.connect(addr1).mint("uclid1Addr", { value: mintingFee });
      expect(await probeNode.ownerOf(1)).to.equal(addr1.address);
      expect(await probeNode.totalSupply()).to.equal(1);
    });

    it("Should fail to mint without correct fee", async function () {
      await expect(
        probeNode
          .connect(addr1)
          .mint("uclid1Addr", { value: ethers.parseEther("0.0001") })
      ).to.be.revertedWith("Minting requires the correct fee");
    });
  });

  describe("Burning", function () {
    it("Should burn a token", async function () {
      await probeNode.connect(addr1).mint("uclid1Addr", { value: mintingFee });
      await probeNode.connect(addr1).burn(1);
      try {
        await probeNode.ownerOf(1);
        throw new Error("Token should not exist");
      } catch (error) {
        expect(error.message).to.include("ERC721NonexistentToken");
      }
      expect(await probeNode.totalSupply()).to.equal(0);
    });
  });

  describe("Withdraw", function () {
    it("Should allow the owner to withdraw funds", async function () {
      await probeNode.connect(addr1).mint("uclid1Addr", { value: mintingFee });
      const initialBalance = await ethers.provider.getBalance(owner.address);
      await probeNode.connect(owner).withdraw(owner.address, mintingFee);
      const finalBalance = await ethers.provider.getBalance(owner.address);
      expect(finalBalance).to.be.above(initialBalance);
    });

    it("Should fail if non-owner tries to withdraw funds", async function () {
      await probeNode.connect(addr1).mint("uclid1Addr", { value: mintingFee });
      try {
        await probeNode.connect(addr1).withdraw(addr1.address, mintingFee);
        throw new Error("Non-owner should not be able to withdraw funds");
      } catch (error) {
        expect(error.message).to.include("OwnableUnauthorizedAccount");
      }
    });
  });

  describe("Pagination and Fetching", function () {
    beforeEach(async function () {
      await probeNode.connect(addr1).mint("uclid1Addr1", { value: mintingFee });
      await probeNode.connect(addr2).mint("uclid1Addr2", { value: mintingFee });
    });

    it("Should return paginated token data", async function () {
      const tokens = await probeNode.getTokenDataPaginated(0, 2, false);
      expect(tokens.length).to.equal(2);
      expect(tokens[0].addr).to.equal(addr1.address);
      expect(tokens[1].addr).to.equal(addr2.address);
    });

    it("Should return tokens owned by an address", async function () {
      const tokens = await probeNode.getTokensByAddress(addr1.address);
      expect(tokens.length).to.equal(1);
      expect(tokens[0].addr).to.equal(addr1.address);
    });
  });
});
