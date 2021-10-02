require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

const ALCHEMY_API_KEY = 'https://eth-rinkeby.alchemyapi.io/v2/DA-gUdq6b1b6WSUgc7EQAxOXx7mdiN1H';
const RINKEBY_PRIVATE_KEY = "c24be8e72ba710725d5a4c1509be4af7737b2e0188c9105b5f24473862752f40";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.4",
  networks: {
    // hardhat: {
    //   accounts: {
    //     count: 27
    //   }
    // },
    rinkeby: {
      url: ALCHEMY_API_KEY,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`],
    },
  }
};
