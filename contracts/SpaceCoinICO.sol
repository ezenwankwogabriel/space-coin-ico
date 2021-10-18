// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

import "./SpaceCoinToken.sol";

contract ICO is Ownable, Pausable {

  SpaceCoin spaceCoin;

  enum Funding {
    Private,
    Public,
    Open
  }

  Funding public state = Funding.Private;

  uint totalPrivateContribution = 15000 ether;
  uint public totalPublicContribution = 30000 ether;
  uint maxPrivateContribution = 1500 ether;
  uint maxPublicContribution = 1000 ether;
  uint public totalContributed;
  bool tokenReleased;

  address treasury;
  address[] public contributors;
  
  // address to funding to amount mapping

  mapping(address => uint) public contributions;
  mapping(address => uint) public tokens;
  
  mapping(address => bool) private _whitelistedAddress;

  event Contributed(address from, uint amount);
  event PublicContribution(address from, uint amount);
  event MovedPhaseForward(Funding value);

  constructor(address _treasury) {
    spaceCoin = new SpaceCoin(_treasury);
    treasury = _treasury;
  }

  modifier verifyState(Funding value) {
    require(state == value);
    _;
  }

  function addWhitelistedAddress(address _address) public onlyOwner {
    require(!_whitelistedAddress[_address], "BAD_REQUEST: Address is already whitelisted");
    _whitelistedAddress[_address] = true;
  }

  modifier canContribute(address from, uint amount) {
    uint contributed = contributions[from];
    uint max;
    uint contributionLimit;

    if (state == Funding.Private) {
      require(_whitelistedAddress[from], "Address is not a whiteslisted contributor");
      contributionLimit = totalPrivateContribution;
      max = maxPrivateContribution;
    }

    if (state == Funding.Public) {
      contributionLimit = totalPublicContribution;
      max = maxPublicContribution;
    }

    require(state == Funding.Open || totalContributed < contributionLimit, "BAD_REQUEST: Contribution limit reached");
    require(state == Funding.Open || contributed + amount <= max, "BAD_REQUEST: Individual contribution exceeds maximum");
    _;
  }

  function contribute(address _address) 
    public payable
    whenNotPaused
    canContribute(_address, msg.value)
  {
    totalContributed += msg.value;
    contributions[_address] += msg.value;    

    if (totalContributed == totalPrivateContribution) {
      state = Funding.Public;
    }

    if (totalContributed == totalPublicContribution) {
      state = Funding.Open;
    }
    
    emit Contributed(_address, msg.value);
  }

  function movePhaseForward(Funding value) public onlyOwner {
    if (Funding.Public == value) {
      require(state == Funding.Private, "Phased can only be moved to public from private");
      state = Funding.Public;
    } else if (Funding.Open == value) {
      require(state == Funding.Public, "Phased can only be moved to Open from Public");
      state = Funding.Open;
    }

    emit MovedPhaseForward(state);
  }

  function balanceOf(address account) public view returns (uint) {
    return spaceCoin.balanceOf(account);
  }

  function treasuryBalance() public view onlyOwner returns (uint) {
    return spaceCoin.getTreasuryAmount();
  }

  function contributedFunds() public view returns (uint) {
    return contributions[msg.sender];
  }

  function pauseFundRaising() public onlyOwner {
    _pause();
  }

  function resumeFundRaising() public onlyOwner {
    _unpause();
  }

  function isWhitelistedAddress(address _address) public view onlyOwner returns(bool) {
    return _whitelistedAddress[_address];
  }

  function redeem() public verifyState(Funding.Open) {
    require(contributions[msg.sender] > 0, "BAD_REQUEST: No contributed fund");

    uint amount = contributions[msg.sender];
    contributions[msg.sender] = 0;

    spaceCoin.transfer(msg.sender, amount * 5 / 1 ether);
  }

  function withdraw() external {
    require(msg.sender == treasury, "Only treasury can call withdraw eth");

    uint amount = address(this).balance;
    (bool sent, ) = address(treasury).call{ value: amount }("");
    require(sent, "Error withdrawing eth");

  }

  function withdrawSpc(uint256 amount) external {
    uint balance = spaceCoin.balanceOf(msg.sender);
    require(balance > amount, "INSUFFICIENT_FUNDS");
    spaceCoin.approve(msg.sender, amount);
  }
}