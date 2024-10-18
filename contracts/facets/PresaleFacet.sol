// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract PresaleFacet {
    uint256 public constant PRICE_PER_NFT = 33333333333333333; // 1 ether / 30 as an integer
    uint256 public constant MIN_PURCHASE = 0.01 ether;

    // Declare the nftFacet variable
    INFTFacet public nftFacet;

    // Add a constructor to initialize nftFacet
    constructor(address _nftFacetAddress) {
        nftFacet = INFTFacet(_nftFacetAddress);
    }

    function buyNFTs() external payable {
        require(msg.value >= MIN_PURCHASE, "Minimum purchase is 0.01 ETH");

        uint256 numberOfNFTs = msg.value / PRICE_PER_NFT;
        // Logic to mint and transfer NFTs to msg.sender
        nftFacet.mint(msg.sender, numberOfNFTs);
        payable(msg.sender).transfer(msg.value - (numberOfNFTs * PRICE_PER_NFT));
        // emit NFTMinted(msg.sender, numberOfNFTs);
    }
}

// Define the interface for the NFTFacet contract
interface INFTFacet {
    function mint(address to, uint256 numberOfNFTs) external;
}
