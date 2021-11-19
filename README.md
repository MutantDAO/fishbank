# FISHBANK

This set of smart contracts will manage fees in FISH for the mutant DAO.  

## Depositor Usage

### Create and register a depositor app

App developer can make their apps into a fish burning app by extending the `FishDepositor` contract like so:

```solidity

import "MutantDAO/fishsink/src/FishDepositor.sol"

contract MyContract is FishDepositor {
  // The following will be the wallet address allowed to withdraw fish rewards for this depositor.
  // The wallet address must be separate from the app address.
  address constant MAINTAINER = 0x111111111111111111111111111111111111111111; 

  constructor(address _fishBankContract) Depositor(_fishBankContract, MAINTAINER) {}

  function takeMyFish(uint256 _amount){
    // This interacts with the `_fishBankContract` which causes the `_amount` in fish to be transferred to the contract.
    _doFishDeposit(_amount);
  }
}

```

## Admin functions

### Withhold reward access

Connect the owner wallet to etherscan.

Run the following contract method on the Fishbank contract to block withdrawal for a particular app:

```solidity
fishbank.block(address _app);
```

To set a new withdrawal address for an app you can use the `adminRegister` function:

```solidity
fishbank.adminRegister(address _app, address _maintainer);
```

### Halt contract

This will cause all deposits to fail and lock withdrawals. Funds will be able to be withdrawn by the owner only.


Connect the owner wallet to etherscan.


```solidity
fishbank.toggleEmergency();
```

Now you can withdraw the funds and reallocate them as required. This method will not work when it is not an emergency.

```solidity
fishbank.withdrawEmergency();
```


## Compiling

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



### Usage

1. Deployer deploys `fishsink` contract

2. Deployer recieves addresses for registration and registers those addresses withthe contract:

```solidity
fishsink.register(appContract1, developer1);
fishsink.register(appContract2, developer2);
fishsink.register(appContract3, developer3);
fishsink.register(appContract4, developer4);
```

Developers can register more than one app contract.

3. Live applications approve a transfer and call the deposit method.

```solidity
ERC20(fish).approve(fishsink, 100 ether);
Fishsink(fishsink).deposit(100 ether);
```

4. Whenever they want to developers can claim their fees.

- Go to the fishsink contract on etherscan.
- Call `balanceOf(mywallet)` to check your balance.
- Connect your wallet and call the `withdrawal()` method pay the gas and your balance will be sent to your wallet.

5. In the case of problematic behaviour rewards can be removed by reregistering the app with address(0)

```solidity
fishsink.register(appContract1, address(0)); // Disable withdrawals
```
