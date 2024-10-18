// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract PresaleFacet {
    uint256 public constant PRICE_PER_NFT = 1 ether / 30;
    uint256 public constant MIN_PURCHASE = 0.01 ether;

    function buyNFTs() external payable {
        require(msg.value >= MIN_PURCHASE, "Minimum purchase is 0.01 ETH");

        uint256 numberOfNFTs = msg.value / PRICE_PER_NFT;
        // Logic to mint and transfer NFTs to msg.sender
    }
}