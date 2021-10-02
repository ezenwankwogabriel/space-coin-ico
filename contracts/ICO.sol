// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol";

import "./CoinToken.sol";

contract ICO is Ownable, Pausable {

  SpaceCoin public token;

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

  address[] public contributors;
  
  // address to funding to amount mapping

  mapping(address => mapping(Funding => uint)) public fundingContributions;
  mapping(address => uint) public contributions;
  mapping(address => uint) public tokens;
  
  mapping(address => bool) private _whitelistedAddress;

  event Contributed(address from, uint amount);
  event PublicContribution(address from, uint amount);
  event MovedPhaseForward(Funding value);

  constructor(address treasury) {
    token = new SpaceCoin(treasury);
  }

  modifier canContribute(address contributor) {
    if (state == Funding.Private) {
      require(_whitelistedAddress[contributor], "Address is not a whiteslisted contributor");
    }
    _;
  }

  modifier verifyState(Funding value) {
    require(state == value);
    _;
  }

  modifier checkContributionLimit() {
    if (state != Funding.Open) {
      uint limit;
      if (state == Funding.Private) {
        limit = totalPrivateContribution;
      } else if (state == Funding.Public) {
        limit = totalPublicContribution;
      }
      require(totalContributed < limit, "BAD_REQUEST: Contribution limit reached");
    }
    _;
  }

  modifier isTokenReleased() {
    require(!tokenReleased, "Token is already released");
    _;
  }

  function addWhitelistedAddress(address _address) public onlyOwner {
    require(!_whitelistedAddress[_address], "BAD_REQUEST: Address is already whitelisted");
    _whitelistedAddress[_address] = true;
  }

  function handleContribution(address from, uint amount) private {
    uint max;
    uint _contribution;
  
    if (state == Funding.Open) {
      fundingContributions[from][Funding.Open] += amount;
    } else {
      if (state == Funding.Private) {
        fundingContributions[from][Funding.Private] += amount;
        _contribution = fundingContributions[from][Funding.Private];
        max = maxPrivateContribution;
      } else if (state == Funding.Public) {
        max = maxPublicContribution;
        fundingContributions[from][Funding.Public] += amount;
        _contribution = fundingContributions[from][Funding.Public];
      }
      
      require(_contribution <= max, "BAD_REQUEST: Individual contribution exceeds limit");
    }
  }

  function contribute() public payable {
    contribute(msg.sender);
  }

  function contribute(address _address) 
    private
    whenNotPaused
    canContribute(_address)
    checkContributionLimit
  {
    handleContribution(_address, msg.value);

    totalContributed += msg.value;
    contributions[_address] += msg.value;    

    if (totalContributed == totalPrivateContribution) {
      state = Funding.Public;
    }

    if (totalContributed == totalPublicContribution) {
      state = Funding.Open;
    }
    
    if (totalContributed > totalPublicContribution) {
      token.transferToken(_address, msg.value * 5 / 1 ether);
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

  // function releaseTokens() private isTokenReleased verifyState(Funding.Open) {
  //   tokenReleased = true;
  //   for (uint8 i = 0; i < contributors.length; i++) {
  //     address contributor = contributors[i];

  //     uint tokenAmount = contributions[contributor] * 5 / 1 ether;

  //     token.transferToken(contributor, tokenAmount);
  //   }
  // }

  function balanceOf(address account) public view returns (uint) {
    return token.balanceOf(account);
  }

  function treasuryBalance() public view onlyOwner returns (uint) {
    return token.getTreasuryAmount();
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

  function withdraw() public verifyState(Funding.Open) {
    require(contributions[msg.sender] > 0, "BAD_REQUEST: No contributed fund");

    uint amount = contributions[msg.sender];
    contributions[msg.sender] = 0;

    token.transferToken(msg.sender, amount * 5 / 1 ether);
  }

}