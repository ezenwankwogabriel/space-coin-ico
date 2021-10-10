const { expect } = require("chai");
const { ethers } = require("hardhat");

const provider = ethers.getDefaultProvider();

function parseEther(amount) {
  return ethers.utils.parseEther(String(amount));
}

const state = {
  private: 0,
  public: 1,
  open: 2
}

describe("ICO", function () {
  
  let owner, treasury, accounts, privateAddresses, publicAddresses;

  beforeEach(async() => {
    [owner, ...accounts] = await ethers.getSigners();
    privateAddresses = accounts.slice(0, 10)
    publicAddresses = accounts.slice(11, 26)
    treasury = accounts[accounts.length - 1].address;

    const ICO = await ethers.getContractFactory("ICO");
    ico = await ICO.deploy(treasury);
  });

  describe("deploys token", () => {
    it('Verifies contract was successfully created', async () => {
      expect(await ico.totalPublicContribution()).to.equal(parseEther(30000));
    })
  })

  describe("Private whitelisted contributor", () => {
    it('Verifies an address is a private contributor', async () => {
      await ico.addWhitelistedAddress(privateAddresses[4].address);
      const isWhitelisted = await ico.isWhitelistedAddress(privateAddresses[4].address);
      expect(isWhitelisted).to.equal(true);
    })

    it('Verifies starting phase is Private', async () => {
      expect(await ico.state()).to.equal(state.private);
    })

    it('Can contribute as a private contributor to max of 1500 ether', async () => {
      const { address: address1 } = privateAddresses[0];
      const { address: address2 } = privateAddresses[1];
      
      await ico.addWhitelistedAddress(address1);
      await ico.addWhitelistedAddress(address2);

      const tx1 = await ico.connect(privateAddresses[0]).contribute(address1, { value: parseEther(1000) });
      const tx2 = await ico.connect(privateAddresses[1]).contribute(address2, { value: parseEther(1500) });

      expect(tx1).to.emit(ico, 'Contributed').withArgs(address1, parseEther(1000))
      expect(tx2).to.emit(ico, 'Contributed').withArgs(address2, parseEther(1500))
    })

    it('Rejects contribution from private contributor exceeding 1500 ether', async () => {
      let error, message;
      try {
        const { address } = privateAddresses[0];
        await ico.addWhitelistedAddress(address);
        await ico.connect(privateAddresses[0]).contribute(address, { value: parseEther(1600) });
      } catch(ex) {
        error = true;
        message = ex.message;
      }

      expect(error).to.equal(true);
      expect(message).to.include('BAD_REQUEST: Individual contribution exceeds maximum');
    })

    it('Changes state to public when contribution is 15000 ether', async () => {
      for (let i = 0; i < privateAddresses.length; i++) {
        await ico.addWhitelistedAddress(privateAddresses[i].address);
        await ico.connect(privateAddresses[i]).contribute(privateAddresses[i].address, { value: parseEther(1500) });
      }

      expect(await ico.state()).to.equal(state.public);
      expect(await ico.totalContributed()).to.equal(parseEther(15000));
    })
  })

  describe('Public contribution', () => {
    beforeEach(async() => {
      for (let i = 0; i < privateAddresses.length; i++) {
        const { address } = privateAddresses[i];
        await ico.addWhitelistedAddress(address);
        await ico.connect(privateAddresses[i]).contribute(privateAddresses[i].address, { value: parseEther(1500) });
      }
    })

    it('expects state to be public', async () => {
      expect(await ico.state()).to.equal(state.public);
    })

    it('can contribute to the ico', async () => {
      const address = accounts[12].address;
      const tx = await ico.connect(accounts[12]).contribute(address, { value: parseEther(1000) });

      expect(tx).to.emit(ico, 'Contributed').withArgs(address, parseEther(1000));
    })

    it('rejects individual contributions above 1000 ether', async () => {
      let error, message;
      try {
        const address = accounts[12].address;
        expect(await ico.state()).to.equal(state.public);
        await ico.connect(accounts[12]).contribute(address, { value: parseEther(1200) });
      } catch(ex) {
        error = true;
        message = ex.message;
      }

      expect(error).to.equal(true);
      expect(message).to.include('BAD_REQUEST: Individual contribution exceeds maximum');
    })

    it('changes state to open when total contribution is 30000 ether: set to run with 27 accounts', async () => {
      let error = false
      try {
        for (let i = 0; i < publicAddresses.length; i++) {
          await ico.connect(publicAddresses[i]).contribute(publicAddresses[i].address, { value: parseEther(1000) });
        }
  
        expect(await ico.totalContributed()).to.equal(parseEther(30000));
        expect(await ico.state()).to.equal(state.open);
      } catch (ex) {
        error = true
      }

      expect(error).to.equal(false)
    })
  })

  describe('Withdraw', () => {
    it ('can withdraw contributed funds in phase OPEN', async () => {
      let error = false;
      try {
        await ico.movePhaseForward(1);
        await ico.movePhaseForward(2);
  
        expect(await ico.state()).to.equal(2);
  
        const tx = await ico.connect(publicAddresses[1]).contribute(publicAddresses[1].address, { value: parseEther(1500) });
        expect(tx).to.emit(ico, 'Contributed').withArgs(publicAddresses[1].address, parseEther(1500))
        const cont = await ico.connect(publicAddresses[1]).contributedFunds();
        await ico.connect(publicAddresses[1]).redeem();
  
        const balance = await ico.connect(publicAddresses[1]).balanceOf(publicAddresses[1].address);
  
        expect(balance).to.equal(7500)
      } catch(ex) {
        error = true;
      }
      expect(error).to.equal(false);
    })
  })

  // describe('Only Owner Switch Tax', () => {
  //   it('can turn tax on', async () => {

  //   })
  //   it('can turn tax off', async () => {

  //   })
  // })

  describe('Pausable', () => {
    it('owner can pause fundraising', async() => {
      await ico.pauseFundRaising();
      expect(await ico.paused()).to.equal(true);
    })
    it('owner can resume a paused fundraising', async() => {
      await ico.pauseFundRaising();
      await ico.resumeFundRaising();
      expect(await ico.paused()).to.equal(false);
    })
    it('only owner can pause/resume minting', async() => {
      let errorOnPause, errorOnResume;
      try {
        await ico.connect(accounts[0].address).pauseFundRaising();
      } catch (ex) {
        errorOnPause = true;
      }

      try {
        await ico.pauseFundRaising();
        await ico.connect(accounts[0].address).resumeFundRaising();
      } catch (ex) {
        errorOnResume = true;
      }

      expect(errorOnPause).to.equal(true);
      expect(errorOnResume).to.equal(true);
    })
    it('cannot contribute to a contract when fundraising is paused', async () => {
      let error, message;
      try {
        await ico.pauseFundRaising();
        await ico.connect(privateAddresses[0]).contribute(privateAddresses[0].address, { value: parseEther(100) })
      } catch (ex) {
        message = ex.message;
        error = true;
      }

      expect(message).to.include('Pausable: paused');
      expect(error).to.equal(true);
    })
  })
});
