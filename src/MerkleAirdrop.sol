// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { MerkleProof } from "openzeppelin/utils/cryptography/MerkleProof.sol";
import { IERC20, SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Merkle Airdrop - Airdrop tokens to users who can prove they are in a merkle tree
 */
contract MerkleAirdrop {
    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive

    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();

    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address => bool) private s_hasClaimed;

    event Claim(address indexed account, uint256 indexed amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    // allow someone in the list to claim some tokens
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        // If an attacker were to find two different inputs that produce the same hash (a collision)
        // with a single hash function, they could potentially manipulate data in a Merkle tree.
        // Double hashing makes it significantly harder to find two inputs that collide at the leaf level,
        // as it requires collisions for two different rounds of hashing.
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true; // prevent users claiming more than once and draining the contract
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }
}
