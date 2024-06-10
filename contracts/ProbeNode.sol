// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract ProbeNode is ERC721URIStorage, Ownable, ReentrancyGuard {
    uint256 private _tokenIdCounter;
    uint256 private _burnedTokensCounter;
    uint256 public mintingFee; // Variable for minting fee
    string private _baseURIextended; // modifiable baseUri
    string private _metaURI; // Common URI for all tokens

    struct TokenData {
        uint256 id;
        address addr; // EVM owner address (0x....)
        string opsAddr; // Node operation address (uclid1....)
        string uri;
    }

    // All tokens
    TokenData[] public allTokens;

    constructor(
        address initialOwner,
        string memory baseURI_,
        string memory metaURI_,
        uint256 initialMintingFee
    ) Ownable(initialOwner) ERC721("Probe Node", "PRBN") {
        setBaseURI(baseURI_);
        setMetaURI(metaURI_);
        mintingFee = initialMintingFee;
    }

    function _baseURI() internal view override returns (string memory) {
        return _baseURIextended;
    }

    function baseURI() public view returns (string memory) {
        return _baseURIextended;
    }

    // Function to check if a token exists
    function exists(uint256 tokenId) public view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    // Owner can modify the baseUri
    function setBaseURI(string memory baseURI_) public onlyOwner {
        _baseURIextended = baseURI_;
    }

    // Owner can modify the meta URI
    function setMetaURI(string memory metaURI_) public onlyOwner {
        _metaURI = metaURI_;
    }

    // Owner can modify the minting fee
    function setMintingFee(uint256 fee) public onlyOwner {
        mintingFee = fee;
    }

    // Mint function with a common URI
    function mint(string memory opsAddr) public payable nonReentrant {
        require(msg.value == mintingFee, "Minting requires the correct fee");

        _tokenIdCounter += 1;

        // Token data for paginated searching
        TokenData memory newTokenData = TokenData({
            id: _tokenIdCounter,
            addr: msg.sender,
            uri: _metaURI,
            opsAddr: opsAddr
        });
        allTokens.push(newTokenData);

        _safeMint(msg.sender, _tokenIdCounter);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(
            exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(_baseURIextended, _metaURI));
    }

    // Burn token
    function burn(uint256 tokenId) public nonReentrant {
        require(
            ownerOf(tokenId) == _msgSender(),
            "caller is not owner nor approved"
        );
        _burn(tokenId);
        _burnedTokensCounter += 1;

        for (uint256 i = 0; i < allTokens.length; i++) {
            if (allTokens[i].id == tokenId) {
                allTokens[i].addr = address(0);
                allTokens[i].opsAddr = "";
            }
        }
    }

    // Allows the contract owner to withdraw accumulated fees to another address
    function withdraw(
        address payable recipient,
        uint256 amount
    ) public onlyOwner nonReentrant {
        uint balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        require(amount <= balance, "Amount exceeds balance");

        // Use Checks-Effects-Interactions pattern
        balance = balance - amount; // Effect
        (bool success, ) = recipient.call{value: amount}(""); // Interaction
        require(success, "Transfer failed.");
    }

    /* --- UTILITY FUNCTION SECTION --- */
    /* -------------------------------- */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter - _burnedTokensCounter;
    }

    function totalBurned() public view returns (uint256) {
        return _burnedTokensCounter;
    }

    // Fetch token data by pagination parameters
    function getTokenDataPaginated(
        uint offset,
        uint count,
        bool reverse
    ) public view returns (TokenData[] memory) {
        require(offset < allTokens.length, "Offset out of bounds.");

        uint total = offset + count > allTokens.length
            ? allTokens.length - offset
            : count;
        uint current = 0;

        TokenData[] memory result = new TokenData[](total);
        if (reverse) {
            while (current < total) {
                result[current] = allTokens[
                    allTokens.length - 1 - offset - current
                ];
                current++;
            }
        } else {
            while (current < total) {
                result[current] = allTokens[offset + current];
                current++;
            }
        }

        return result;
    }

    // Fetch all tokens owned by an address
    function getTokensByAddress(
        address addr
    ) public view returns (TokenData[] memory) {
        uint256 tokenCount = 0;
        // First, count the number of tokens owned by the address.
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (allTokens[i].addr == addr) {
                tokenCount++;
            }
        }

        // Create an array of the number of tokens owned by the address.
        TokenData[] memory tokens = new TokenData[](tokenCount);
        uint256 index = 0;
        for (uint256 i = 0; i < allTokens.length; i++) {
            if (allTokens[i].addr == addr) {
                tokens[index] = allTokens[i];
                index++;
            }
        }

        return tokens;
    }
}
