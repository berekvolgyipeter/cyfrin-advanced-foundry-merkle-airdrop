// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import { ERC20 } from "openzeppelin/token/ERC20/ERC20.sol";
import { Ownable } from "openzeppelin/access/Ownable.sol";

contract BagelToken is ERC20, Ownable {
    constructor() ERC20("Bagel Token", "BT") Ownable(msg.sender) { }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
