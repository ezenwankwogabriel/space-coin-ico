// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20, Ownable {
    uint constant totalSupply_ = 300000 ether;

    constructor() ERC20("SpaceCoinLiquidityPoolToken", "SPLPT") {
        _mint(msg.sender, totalSupply_);
    }
}