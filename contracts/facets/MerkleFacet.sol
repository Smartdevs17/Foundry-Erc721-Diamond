// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleFacet {
    bytes32 public merkleRoot;

    function setMerkleRoot(bytes32 _merkleRoot) external {
        LibDiamond.enforceIsContractOwner();
        merkleRoot = _merkleRoot;
    }

    function claimNFT(bytes32[] calldata _merkleProof, uint256 tokenId) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, tokenId));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");

    }
}