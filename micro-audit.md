# Micro-audit

Done by: Kyle Baker
Date: Oct 4 2021
Repo: https://github.com/ezenwankwogabriel/space-coin-ico
Commit: f8b7d750d716fa336597909b082e7dbf48e7b09d


## issues

### file: contracts/CoinToken.sol 

#### line: 12-17
severity: code quality
comments: Declaration of `totalSupply_` is unnecessarily preserved on the blockchain. Because it is only ever used once on construction, gas would be saved and code clarified and simplified by only declaring this variable within the constructor, which is not stored on-chain.
recommendation: Remove `totalSupply_` and add `500000 ether` on line 16 directly. Alternatively, can instead declare `totalSupply_` within the constructor, which would set it only as a brief `memory` allocation.
```
    constructor(address _treasury) ERC20("SpaceCoin", "SPC") {
      treasury = _treasury;
      _mint(msg.sender, 500000 ether);
    }
```


#### line: 23-31
severity: high (multiple)
comments: `transferToken()` has various errors. (1) taxes 20%, not 2%. (2) transferToken is not ERC20 compliant; because it inherits from open-zeppelin `ERC20` contract, it has the various appropriate `transfer` methods exposed, but none of those methods will have tax implemented. 
recommendation: Instead, override `_transfer()`, which is utilized as consistent transfer logic among all `ERC20`, and is therefore an ideal place to insert a consistent tax across all transfers for the token. 
```
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (taxOn) {
            ERC20._transfer(sender, treasury, (amount / 100) * 2);
            ERC20._transfer(sender, recipient, (amount / 100) * (100 - 2) );
        } else {
            ERC20._transfer(sender, recipient, amount);
        }
    }
```


#### line: 19-21
severity: code quality
comments: `_msgSender()` override seems to be unnecessary waste of gas that changes nothing. Commenting this out does not cause a change in test results.
recommendation: Remove superfluous override.



#### line: N/A
severity: high
comments: ERC20 critical methods are not implemented; there is no way for users to transfer tokens to each other once the open phase is reached.
recommendation: Use contract inheritance instead of contract instance declaration with `new` to expose the appoprtiate ERC20 methods (e.g. `transfer()`).
```
contract ICO is Ownable, Pausable, SpaceCoin {
```
see: https://solidity-by-example.org/inheritance/







### file: contracts/ICO.sol 

#### line: 71-74
severity: code quality
comments: `isTokenReleased()` modifier is never used.
```
  modifier isTokenReleased() {
    require(!tokenReleased, "Token is already released");
    _;
  }
```
recommendation: Remove unused code.
note: this is also the case on line 28, and seems to be a consistent thing. Will not mention further--code should just be refactored to remove unused code.


#### line: 85-99
severity: code quality (multiple)
comments: `handleContribution()` is ambiguously named, and features unnecessary `if` block nesting.
recommendation: 
(1) Rename method to `checkIfContributionIsWithinLimit()`, or `confirmContributionAllowed()`, etc.
(2) Change from:
```
if () {

} else {
    if () {

    } else if () {

    }  
}
```
To:
```
if () {

} else if () {

} else if () {

}  
```


#### line: 102/106
severity: code quality
comments: Function overriding serves no purpose here
recommendation:
Change from
```
  function contribute() public payable {
    contribute(msg.sender);
  }

  function contribute(address _address) 
  {
    handleContribution(_address, msg.value);

```
To
```
  function contribute(address _address) public payable
  {
    handleContribution(msg.sender, msg.value);
```

#### line: 126
severity: high
comments: Tax is applied to coin purchase instead of coin transfers
recommendation: Include fix as part of general code updates required in response to issue lised on line 25 of this document.






### file: test/ico.js 

#### line: 163-170
severity: code quality
comments: Test is not implemented, but test defaults to 'passing'. Tests should fail by default when not implemented to prevent accidental misleading information.
```

```js
describe('Only Owner Switch Tax', () => {
  it('can turn tax on', async () => {

  })
  it('can turn tax off', async () => {

  })
})

```


### other notes
- In state repo was provided, test was failing for "changes state to open when total contribution is 30000 ether". However, investigation showed the failure to be due to commented out configuration that allowed correct number (27) of contributors for this code to pass. It is presumed this was a minor mistake of no consequence; when uncommented, the test passes.
