# Prerequisites

- [dapptools](https://github.com/dapphub/dapptools)

# Installation

```
./install.sh
```

# Testing

```
./test.sh
```

# Usage

1. Deployer deploys `fishsink` contract

2. Deployer recieves addresses for registration and registers those addresses withthe contract:

```
fishsink.register(appContract1, developer1);
fishsink.register(appContract2, developer2);
fishsink.register(appContract3, developer3);
fishsink.register(appContract4, developer4);
```

Developers can register more than one app contract.

3. Live applications approve a transfer and call the deposit method.

```sol
ERC20(fish).approve(fishsink, 100 ether);
Fishsink(fishsink).deposit(100 ether);
```

4. Whenever they want to developers can claim their fees.

- Go to the fishsink contract on etherscan.
- Call `balanceOf(mywallet)` to check your balance.
- Connect your wallet and call the `withdrawal()` method pay the gas and your balance will be sent to your wallet.

5. In the case of problematic behaviour rewards can be removed by reregistering the app with address(0)

```
fishsink.register(appContract1, address(0)); // Disable withdrawals
```
