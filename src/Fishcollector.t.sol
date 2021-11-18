// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Fishcollector.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Fish is ERC20 {
    constructor(string memory _name, string memory _thing)
        ERC20(_name, _thing)
    {}

    function mint(address _address, uint256 _amount) public {
        _mint(_address, _amount);
    }
}

contract TokenUser {
    IERC20 token;

    constructor(IERC20 token_) {
        token = token_;
    }

    function doTransferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        return token.transferFrom(from, to, amount);
    }

    function doTransfer(address to, uint256 amount) public returns (bool) {
        return token.transfer(to, amount);
    }

    function doApprove(address recipient, uint256 amount)
        public
        returns (bool)
    {
        return token.approve(recipient, amount);
    }

    function doAllowance(address owner, address spender)
        public
        view
        returns (uint256)
    {
        return token.allowance(owner, spender);
    }

    function doBalanceOf(address who) public view returns (uint256) {
        return token.balanceOf(who);
    }
}

contract FishCollectorUser is TokenUser {
    Fishcollector c;

    constructor(Fishcollector _c, IERC20 _fish) TokenUser(_fish) {
        c = _c;
    }

    function deposit(uint256 _amount) public {
        c.deposit(_amount);
    }

    function withdrawal() public {
        c.withdrawal();
    }
}

contract FishcollectorTest is DSTest {
    uint256 constant initialBalanceThis = 0;
    uint256 constant initialBalanceApp = 200 ether;
    uint256 constant initialBalanceController = 200 ether;

    Fishcollector fishcollector;
    Fish fish;
    address sink;

    address app;
    address controller;

    function setUp() public {
        sink = address(this);
        fish = new Fish("FISH", "FISH");
        fishcollector = new Fishcollector(sink, address(fish));
        app = address(new FishCollectorUser(fishcollector, fish));
        controller = address(new FishCollectorUser(fishcollector, fish));
        fish.mint(app, initialBalanceApp);
        fish.mint(controller, initialBalanceController);
    }

    function approveAndDeposit(
        address _app,
        address _controller,
        uint256 _amount
    ) public {
        fishcollector.register(_app, _controller);
        TokenUser(app).doApprove(address(fishcollector), _amount);
        emit log_named_uint("amount:", _amount);
        FishCollectorUser(app).deposit(_amount);
    }

    function testSetup() public {
        assertEq(fish.balanceOf(address(this)), initialBalanceThis);
        assertEq(fish.balanceOf(app), initialBalanceApp);
        assertEq(fish.balanceOf(controller), initialBalanceController);
        assertEq(fish.balanceOf(address(fishcollector)), 0);
    }

    function testDeposit() public {
        approveAndDeposit(app, controller, 100 ether);
        assertEq(fishcollector.balanceOf(controller), 5 ether);
        assertEq(fishcollector.balanceOf(sink), 95 ether);
        assertEq(fishcollector.balanceOfApp(app), 5 ether);
        assertEq(fish.balanceOf(address(fishcollector)), 100 ether);
    }

    function testFuzzDeposit(uint64 _amount) public {
        fish.mint(app, _amount);
        fish.mint(controller, _amount);
        if (_amount > 0) {
            approveAndDeposit(app, controller, _amount);
        }
    }

    function testFailDepositZero() public {
        approveAndDeposit(app, controller, 0);
    }

    function testDepositWithHigherRate() public {
        fishcollector.setRate(700);
        approveAndDeposit(app, controller, 100 ether);
        assertEq(fishcollector.balanceOf(controller), 7 ether);
        assertEq(fishcollector.balanceOf(sink), 93 ether);
        assertEq(fishcollector.balanceOfApp(app), 7 ether);
        assertEq(fish.balanceOf(address(fishcollector)), 100 ether);
    }

    function testFailRate() public {
        fishcollector.setRate(5100);
    }

    function testFailWhenDepositWithoutRegistration() public {
        uint256 _amount = 100 ether;
        TokenUser(app).doApprove(address(fishcollector), _amount);
        FishCollectorUser(app).deposit(_amount);
    }

    function testFailWhenRegisteringOwnerAsApp() public {
        fishcollector.register(address(this), controller);
    }

    function testFailWhenRegisteringControllerAsApp() public {
        fishcollector.register(controller, controller);
    }

    function testFailWhenRegisteringNullAddressAsController() public {
        fishcollector.register(controller, address(0));
    }

    function testFailWhenRegisteringNullAddressAsApp() public {
        fishcollector.register(address(0), controller);
    }

    function testFailWhenDepositerIsOwner() public {
        uint256 _amount = 100 ether;
        fishcollector.register(address(this), controller);
        fish.approve(address(fishcollector), _amount);
        fishcollector.deposit(_amount);
    }

    function testFailWithdrawalController() public {
        FishCollectorUser(controller).withdrawal();
    }

    function testWithdrawController() public {
        approveAndDeposit(app, controller, 100 ether);
        assertEq(fishcollector.balanceOf(controller), 5 ether);
        FishCollectorUser(controller).withdrawal();
        assertEq(fishcollector.balanceOf(controller), 0);
        assertEq(
            fish.balanceOf(controller),
            initialBalanceController + 5 ether
        );
    }

    function testWithdrawControllerFuzz(uint32 _amount_) public {
        uint256 _amount = uint256(_amount_);
        if (_amount <= 50) return; // Low numbers lead to zero withdrawals
        fish.mint(app, _amount);
        fish.mint(controller, _amount);
        uint256 initBal = fish.balanceOf(controller);
        approveAndDeposit(app, controller, _amount);
        FishCollectorUser(controller).withdrawal();
        assertEq(
            fish.balanceOf(controller),
            initBal + ((_amount * 500) / 10000)
        );
    }
}
