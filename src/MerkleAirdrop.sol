// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract MerkleAirdrop {
    // list of addresses that can receive tokens
    address[] claimers;

    // allow someone in the list to claim some tokens
    function claim(address account) external {
        for (uint256 i = 0; i < claimers.length; i++) {
            // check if the account is in the claimers array
            // but this method is gonna be costly and prone to DoS
        }
    }
}
