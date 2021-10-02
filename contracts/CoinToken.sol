// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SpaceCoin is ERC20, Ownable {
  bool private taxOn;

  address treasury;
  uint totalSupply_ = 500000 ether;

  constructor(address _treasury) ERC20("SpaceCoin", "SPC") {
    treasury = _treasury;
    _mint(msg.sender, totalSupply_);
  }

  function _msgSender() internal view override returns (address) {
    return super._msgSender();
  }

  function transferToken(address to, uint256 amount) public {
    if (taxOn) {
      uint tax = amount * 20 / 100;
      transfer(treasury, tax);
      transfer(to, amount - tax);
    } else {
      transfer(to, amount);
    }
  }

  function toggleTax(bool state) public onlyOwner {
    taxOn = state;
  }

  function getTreasuryAmount() public view onlyOwner returns (uint) {
    return balanceOf(treasury);
  }
}
