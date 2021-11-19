# Prerequisites

- [make](https://www.gnu.org/software/make/)

# Installed dependencies

- [dapp.tools](https://github.com/dapphub/dapptools)
- [nix](https://nixos.org)

# Installation

```
./install.sh
```

This installs:

- nix
- dapp.tools
- solc

# Building

```
make
```

# Testing

```
make test
```

# System

App developers make their apps and include the following code to make a deposit against their app:

```solidity

import "MutantDAO/fishsink/src/FishDepositor.sol"

contract MyContract is FishDepositor {
  address constant MY_ADDRESS = 0x111111111111111111111111111111111111111111; // Use your address here

  constructor(address _fishBankContract) Depositor(_fishBankContract, MY_ADDRESS) {}

  function takeMyFish(uint256 _amount){
    // This interacts with the `_fishBankContract` which causes the `_amount` in fish to be transferred to the contract.
    _doFishDeposit(_amount);
  }
}

```

# Usage

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
