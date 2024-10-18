// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenStorage} from "../libraries/LibAppStorage.sol";
import {LibERC721} from "../libraries/LibERC721.sol";

import "../interfaces/IERC721.sol";


contract DiamondNftFacet is IERC721 {
    // Define a struct to hold NFT data
    struct NFT {
        address owner;
        string metadata;
    }

    // Mapping from token ID to NFT
    mapping(uint256 => NFT) private _nfts;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /// @notice Mints a new NFT with a given token ID and metadata
    function mint(address to, uint256 tokenId, string memory metadata) external {
        require(to != address(0), "ERC721: mint to the zero address");
        require(_nfts[tokenId].owner == address(0), "ERC721: token already minted");

        _nfts[tokenId] = NFT(to, metadata);
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length - 1;

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Returns the owner of the token ID
    function ownerOf(uint256 tokenId) external view override returns (address) {
        address owner = _nfts[tokenId].owner;
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    /// @notice Approves another address to transfer the given token ID
    function approve(address to, uint256 tokenId) external override {
        address owner = _nfts[tokenId].owner;
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender), "ERC721: approve caller is not owner nor approved for all");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// @notice Returns the approved address for a token ID, or zero if no address set
    function getApproved(uint256 tokenId) external view override returns (address) {
        require(_nfts[tokenId].owner != address(0), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    /// @notice Sets or unsets the approval of a given operator
    function setApprovalForAll(address operator, bool approved) external override {
        require(operator != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Tells whether an operator is approved by a given owner
    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /// @notice Transfers the ownership of a given token ID to another address
    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    // Internal function to transfer ownership of a given token ID to another address
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(_nfts[tokenId].owner == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        // Remove token from previous owner
        uint256 lastTokenIndex = _ownedTokens[from].length - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId;
            _ownedTokensIndex[lastTokenId] = tokenIndex;
        }

        _ownedTokens[from].pop();

        // Add token to new owner
        _nfts[tokenId].owner = to;
        _ownedTokens[to].push(tokenId);
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length - 1;

        emit Transfer(from, to, tokenId);
    }

    // Internal function to check if a given spender can transfer a given token ID
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_nfts[tokenId].owner != address(0), "ERC721: operator query for nonexistent token");
        address owner = _nfts[tokenId].owner;
        return (spender == owner || this.getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    // Internal function to approve a given address to transfer a given token ID
    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(_nfts[tokenId].owner, to, tokenId);
    }

    function balanceOf(address owner) external view returns (uint256 balance) {
        balance = _ownedTokens[owner].length;
    }




}
