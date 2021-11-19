# FISHBANK

This set of smart contracts will manage fees in FISH for the mutant DAO.  

## Depositor Usage

### Create and register a depositor app

App developer can make their apps into a fish burning app by extending the `FishDepositor` contract like so:

```solidity

import "MutantDAO/fishsink/src/FishDepositor.sol"

contract MyContract is FishDepositor {
  // The FishDepositor constructor will accept the maintainers wallet address which will be allowed to claim fish rewards for this app.
  // The wallet address must be separate from the app address.
  constructor(address _fishBank) FishDepositor(_fishBank, 0x111111111111111111111111111111111111111111) {}

  function takeMyFish(uint256 _amount){
    // This interacts with the `_fishBankContract` which causes the `_amount` in fish to be transferred to the contract.
    _doFishDeposit(_amount);
  }
}

```

### Check the balance of your maintainer rewards

```solidity
function balanceOf(address _maintainer) public return (uint256)
```

### Claiming rewards

To claim your rewards from the fishBank the relavent maintainer address should be connected to etherscan and the `withdrawal` function called. 

```solidity
function withdraw() public
```

This will send your app rewards to your wallet.


## Admin functions

### Withhold reward access

Connect the owner wallet to etherscan.

Run the following contract method on the Fishbank contract to block withdrawal for a particular app:

```solidity
function block(address _app) public onlyOwner;
```

To set a new withdrawal address for an app you can use the `adminRegister` function:

```solidity
adminRegister(address _app, address _maintainer) public onlyOwner;
```

### Halt contract

This will cause all deposits to fail and lock withdrawals. Funds will be able to be withdrawn by the owner only.


Connect the owner wallet to etherscan.


```solidity
function toggleEmergency() public onlyOwner;
```

Now you can withdraw the funds and reallocate them as required. This method will not work when it is not an emergency.

```solidity
fishbank.withdrawEmergency();
```

---

## Working with this repo

### Prerequisites

- [make](https://www.gnu.org/software/make/)

### Installed dependencies

- [dapp.tools](https://github.com/dapphub/dapptools)
- [nix](https://nixos.org)

### Installation

```
./install.sh
```

This installs:

- nix
- dapp.tools
- solc

### Building

```
make
```

### Testing

```
make test
```

