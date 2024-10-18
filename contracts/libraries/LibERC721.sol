// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {TokenStorage} from "./LibAppStorage.sol";

library LibERC721 {
    error InvalidAddress();
    error TokenAlreadyMinted();
    error TokenNotOwned();
    error ApprovalToCurrentOwner();
    error ApprovalCallerNotOwnerNorApproved();

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(TokenStorage storage ts, address _owner) internal view returns (uint256) {
        if (_owner == address(0)) revert InvalidAddress();
        return ts.balances[_owner];
    }

    function ownerOf(TokenStorage storage ts, uint256 _tokenId) internal view returns (address) {
        address owner = ts.owners[_tokenId];
        if (owner == address(0)) revert InvalidAddress();
        return owner;
    }

    function transferFrom(TokenStorage storage ts, address _from, address _to, uint256 _tokenId) internal {
        if (_to == address(0)) revert InvalidAddress();
        if (ownerOf(ts, _tokenId) != _from) revert TokenNotOwned();

        // Clear approvals from the previous owner
        delete ts.tokenApprovals[_tokenId];

        ts.balances[_from] -= 1;
        ts.balances[_to] += 1;
        ts.owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(TokenStorage storage ts, address _to, uint256 _tokenId) internal {
        address owner = ownerOf(ts, _tokenId);
        if (_to == owner) revert ApprovalToCurrentOwner();
        if (msg.sender != owner && !isApprovedForAll(ts, owner, msg.sender)) revert ApprovalCallerNotOwnerNorApproved();

        ts.tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }

    function isApprovedForAll(TokenStorage storage ts, address _owner, address _operator) internal view returns (bool) {
        return ts.operatorApprovals[_owner][_operator];
    }

    function setApprovalForAll(TokenStorage storage ts, address _operator, bool _approved) internal {
        ts.operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
}
