// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceCoin is ERC20, Ownable {
  bool private taxOn;

  address treasury;
  uint constant totalSupply_ = 500000 ether;

  constructor(address _treasury) ERC20("SpaceCoin", "SPC") {
    _mint(msg.sender, totalSupply_);
    treasury = _treasury;
  }

  function _transfer(
    address sender,
    address recipient,
    uint256 amount
  ) internal virtual override {
    if (taxOn) {
      uint taxAmount = amount * 2 / 100;
      amount = amount - taxAmount;
      super._transfer(sender, treasury, amount * 2 / 100);
    }  
    super._transfer(sender, recipient, amount);
  }

  function toggleTax(bool state) public onlyOwner {
    taxOn = state;
  }

  function getTreasuryAmount() public view onlyOwner returns (uint) {
    return balanceOf(treasury);
  }
}
