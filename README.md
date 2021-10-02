# PROJECT ICO

## Background
This project implements an Initial Coin Offering: creating a token, an ICO contract, and a dapp frontend. Tokens are minted to contributors when they contribute to the ICO project.

# Deployed Contract Address
The ICO contract is deployed on the Rinkeby network, address:
0x24E2cC0FE14BC63047be5AD15D5e700bC545d3F0

## Specs

  - Write an ERC-20 token contract
  - Write an ICO contract
  - Deploy contract to testnet network (Rinkeby)
  - Design frontend for investors to deposit ETH and later withdraw their tokens
  - Tax which can be toggled and is deposited to treasury account

# Development

## Steps to start the app
cd to app folder
install dependencies using `npm i`
compile application using `npx hardhat compile`
deploy application using `npx hardhat run scripts/ico-script.js`

## Steps and commands to run the test
cd to app folder
run test using command `npx hardhat test`

## Deploy to testnet
cd to app folder
run command `npx hardhat run script/ico-script.js --network rinkeby`

## Start frontend application
From app folder, cd into frontend
install a "live server" vs code extension or http-server npm package.
Use installed package to run index.html and test application functionality

