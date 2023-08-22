// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BetReceipt is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(address => uint) public walletMints;

    constructor() ERC721("BetReceipt", "BETR") {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function mintTokens() public {
        walletMints[msg.sender] +=1;
    }
    function burnTokens() public payable  {
        require(walletMints[msg.sender] > 0, "No token minted for this address");
        walletMints[msg.sender] = 0;
    }
    function getWalletMints() view public returns (uint) {
        return walletMints[msg.sender];
    }
}