// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { MerkleProof } from "openzeppelin/utils/cryptography/MerkleProof.sol";
import { IERC20, SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { EIP712 } from "openzeppelin/utils/cryptography/EIP712.sol";
import { ECDSA } from "openzeppelin/utils/cryptography/ECDSA.sol";

/**
 * @title Merkle Airdrop - Airdrop tokens to users who can prove they are in a merkle tree
 */
contract MerkleAirdrop is EIP712 {
    using SafeERC20 for IERC20; // Prevent sending tokens to recipients who can’t receive

    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();
    error MerkleAirdrop__InvalidProof();

    IERC20 private immutable i_airdropToken;
    bytes32 private immutable i_merkleRoot;
    mapping(address => bool) private s_hasClaimed;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    event Claim(address indexed account, uint256 indexed amount);

    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("Merkle Airdrop", "1.0.0") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    // allow someone in the list to claim some tokens
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        if (s_hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }

        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }

        // prevent second preimage attacks -> double hash leaves
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }

        s_hasClaimed[account] = true; // prevent users claiming more than once and draining the contract
        emit Claim(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    // message we expect to have been signed
    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({ account: account, amount: amount })))
        );
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }

    // verify whether the recovered signer is the expected signer/the account to airdrop tokens for
    function _isValidSignature(
        address signer,
        bytes32 digest, // EIP-721 message hash
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        internal
        pure
        returns (bool)
    {
        /// @dev could also use SignatureChecker.isValidSignatureNow(signer, digest, signature)
        // from "openzeppelin/utils/cryptography/SignatureChecker.sol"
        // bytes memory signature = abi.encode(_v, _r, _s);
        (address actualSigner, /*ECDSA.RecoverError recoverError*/, /*bytes32 signatureLength*/ ) =
            ECDSA.tryRecover(digest, _v, _r, _s);
        return (actualSigner == signer);
    }
}
