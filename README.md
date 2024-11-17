# cyfrin-advanced-foundry-merkle-airdrop

## MessageHash

To obtain the data for signing, use the `getMessageHash` function on the `MerkleAirdrop` contract. This function requires an account address, a `uint256` amount, and the Anvil node URL (`http://localhost:8545`).

```zsh
cast call <airdrop address> "getMessageHash(address,uint256)" <account address> <amount to claim> --rpc-url <rpc url>
```

example on anvil:

```zsh
cast call 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "getMessageHash(address,uint256)" 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 25000000000000000000 --rpc-url http://localhost:8545

0x7886453564f3abce484240ab03353027bde591090caf1f82ce22c3487afe9568
```

## Signing

With the data ready for signing, use the `cast wallet sign` command. Include the `--no-hash` flag to prevent rehashing, as the message is already in bytes format. Also, use the `--private-key` flag with the first Anvil private key.

_NOTE:  When working on a testnet or using a real account, avoid using the private key directly. Instead, use the `--account` flag and your keystore account for signing._

```zsh
cast wallet sign --no-hash <message hash> --private-key <private key>
```

example on anvil:

```zsh
cast wallet sign --no-hash 0x7886453564f3abce484240ab03353027bde591090caf1f82ce22c3487afe9568 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

0x04209f8dfd0ef06724e83d623207ba8c33b6690e08772f8887a4eaf9a66b9182188938adea374fa542ad5ddde24bdc981f5e26a628e65fb425a68db8a938f6761c
```
