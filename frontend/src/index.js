const abi = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "treasury",
        "type": "address"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "Contributed",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "enum ICO.Funding",
        "name": "value",
        "type": "uint8"
      }
    ],
    "name": "MovedPhaseForward",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "address",
        "name": "previousOwner",
        "type": "address"
      },
      {
        "indexed": true,
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "OwnershipTransferred",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "account",
        "type": "address"
      }
    ],
    "name": "Paused",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "from",
        "type": "address"
      },
      {
        "indexed": false,
        "internalType": "uint256",
        "name": "amount",
        "type": "uint256"
      }
    ],
    "name": "PublicContribution",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": false,
        "internalType": "address",
        "name": "account",
        "type": "address"
      }
    ],
    "name": "Unpaused",
    "type": "event"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_address",
        "type": "address"
      }
    ],
    "name": "addWhitelistedAddress",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "account",
        "type": "address"
      }
    ],
    "name": "balanceOf",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "contribute",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "contributedFunds",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "contributions",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "name": "contributors",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      },
      {
        "internalType": "enum ICO.Funding",
        "name": "",
        "type": "uint8"
      }
    ],
    "name": "fundingContributions",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_address",
        "type": "address"
      }
    ],
    "name": "isWhitelistedAddress",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "enum ICO.Funding",
        "name": "value",
        "type": "uint8"
      }
    ],
    "name": "movePhaseForward",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "pauseFundRaising",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "paused",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "renounceOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "resumeFundRaising",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "state",
    "outputs": [
      {
        "internalType": "enum ICO.Funding",
        "name": "",
        "type": "uint8"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "token",
    "outputs": [
      {
        "internalType": "contract SpaceCoin",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "name": "tokens",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "totalContributed",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "totalPublicContribution",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "newOwner",
        "type": "address"
      }
    ],
    "name": "transferOwnership",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "treasuryBalance",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "withdraw",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  }
]

const contractAddr = '0x24E2cC0FE14BC63047be5AD15D5e700bC545d3F0'

const provider = new ethers.providers.Web3Provider(window.ethereum)
const signer = provider.getSigner();

const contract = new ethers.Contract(contractAddr, abi, signer);

let signerAddress;

// Read on-chain data when clicking a button
// getGreeting.addEventListener('click', async () => {
//   greetingMsg.innerText = await contract.greet()
// })

// For playing around with in the browser
window.ethers = ethers
window.provider = provider
window.signer = signer
window.contract = contract

// Kick things off
go()

async function go() {
  await connectToMetamask()
}

async function connectToMetamask() {
  try {
    signerAddress = await signer.getAddress();
    console.log("Signed in", signerAddress);
    init();
  } catch(err) {
    console.log("Not signed in", err)
    await provider.send("eth_requestAccounts", [])
  }
}

async function init() {
  try {
    getTotalContributions();
    getTotalPurchase();
    getPhase()
  
    document.getElementById('deposit-ether').addEventListener('click', async () => {
      try {
        let amount = document.getElementById('purchase-amount').value;
        const tx = await depositEther(toWei(amount));
        await getTotalContributions();
      } catch (ex) {
        displayError(ex.message)
      }
    })
  
    document.getElementById('add-whitelist-button').addEventListener('click', async () => {
      try {
        let address = document.getElementById('whitelist-address').value;
        await contract.addWhitelistedAddress(address);
        displaySuccess('Successfully added address');
      } catch(ex) {
        displayError(ex.message);
      }
    })

    document.getElementById('move-forward-button').addEventListener('click', async () => {
      try {
        let phase = document.getElementById('custom-select').value;
        await contract.movePhaseForward(phase);
        await getPhase();
        displaySuccess('Successfully moved phase forward')
      } catch (ex) {
        displayError(ex.message);
      }
    })
  
    document.getElementById('close-error').addEventListener('click', async () => {
      document.getElementById('error-alert-box').classList.remove('show');
    })
  
    document.getElementById('close-success').addEventListener('click', async () => {
      document.getElementById('success-alert-box').classList.remove('show');
    })
  } catch (ex) {
    console.log(ex.message)
  }
}

filter = {
  address: contractAddr,
  topics: [
    // the name of the event, parnetheses containing the data type of each event, no spaces
    // utils.id("Transfer(address,address,uint256)")
  ]
}

async function getTotalContributions() {
  const balance = await contract.contributedFunds();
  document.getElementById('purchased-token-amount').textContent = toEther(balance.toString());
}

async function getTotalPurchase() {
  try {
    const balance = await contract.balanceOf(signerAddress);
    document.getElementById('purchased-token').textContent = toEther(balance.toString()) + ' Ether'
    
  } catch(ex) {
    console.log(ex)
  }
}

async function depositEther(amount) {
  try {
    await contract.contribute({ value: amount })
    await getTotalContributions();
  } catch (ex) {
    displayError(ex.message);
  }
} 

async function getPhase() {
  const phaseStruct = {
    0: 'Private',
    1: 'Public',
    2: 'Open'
  }
  try {
    const value = await contract.state();
    document.getElementById('ico-phase').textContent = phaseStruct[value]
  } catch (ex) {
    displayError(ex.message);
  }
}

async function toWei(value) {
  if (Number(value))
    return ethers.utils.parseEther(value)
  throw new Error('Invalid amount')
}

function toEther(value) {
  console.log('value', value)
  const eth = ethers.utils.formatEther(String(value))
  return Number(eth);
}

function displayError(message) {
  document.getElementById('error-msg').textContent = message;
  document.getElementById('success-alert-box').classList.remove('show');
  document.getElementById('error-alert-box').classList.add('show');
}

function displaySuccess(message) {
  document.getElementById('success-msg').textContent = message;
  document.getElementById('error-alert-box').classList.remove('show');
  document.getElementById('success-alert-box').classList.add('show');
}

provider.on(filter, () => {
  // do whatever you want here
  // I'm pretty sure this returns a promise, so don't forget to resolve it
})