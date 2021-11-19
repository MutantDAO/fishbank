// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Fishbank.sol";
import "./Fishbank.t.sol";
import "./FishDepositor.sol";

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyDepositor is FishDepositor {
    constructor(address _fishBank, address _maintainer)
        FishDepositor(_fishBank, _maintainer)
    {}

    function deposit(uint256 _amount) public {
        _doFishDeposit(_amount);
    }
}

contract FishDepositorTest is DSTest {
    Fishbank fishBank;
    Fish fish;
    address maintainer;
    address sink;
    MyDepositor depositor;

    function setUp() public {
        fish = (new Fish("FISH", "FISH"));
        sink = address(new TokenUser(fish));
        maintainer = address(new TokenUser(fish));
        fishBank = (new Fishbank(sink, address(fish)));
        depositor = new MyDepositor(address(fishBank), maintainer);
    }

    function testDepositorIsRegistered() public {
        assertEq(fishBank.maintainerOf(address(depositor)), maintainer);
    }

    function testDeposit() public {
        fish.mint(address(depositor), 100 ether);
        depositor.deposit(50 ether);
        depositor.deposit(50 ether);
        assertEq(fishBank.balanceOf(address(depositor)), 5 ether);
    }
}
