// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../libraries/LibDiamond.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;
    INFTFacet public nftFacet; // Declare the nftFacet variable

    // Add a constructor or a setter function to initialize nftFacet
    constructor(address _nftFacetAddress) {
        nftFacet = INFTFacet(_nftFacetAddress);
    }

    function setMerkleRoot(bytes32 _merkleRoot) external {
        LibDiamond.enforceIsContractOwner();
        merkleRoot = _merkleRoot;
    }

    function claimNFT(bytes32[] calldata _merkleProof, uint256 tokenId) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, tokenId));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");
        nftFacet.mint(msg.sender, 1);
    }
}

// Define the interface for the NFTFacet contract
interface INFTFacet {
    function mint(address to, uint256 amount) external;
}
