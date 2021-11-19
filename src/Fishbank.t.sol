// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./Fishbank.sol";
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
    Fishbank c;

    constructor(Fishbank _c, IERC20 _fish) TokenUser(_fish) {
        c = _c;
    }

    function deposit(uint256 _amount) public {
        c.deposit(_amount);
    }

    function doWithdraw(address _app) public {
        c.doWithdraw(_app);
    }

    function registerMaintainer(address _maintainer) public {
        c.registerMaintainer(_maintainer);
    }
}

contract FishbankTest is DSTest {
    uint256 constant initialBalanceThis = 0;
    uint256 constant initialBalanceApp = 200 ether;
    uint256 constant initialBalanceController = 200 ether;

    Fishbank fishcollector;
    Fish fish;
    address sink;

    address app;
    address maintainer;

    function setUp() public {
        sink = address(this);
        fish = new Fish("FISH", "FISH");
        fishcollector = new Fishbank(sink, address(fish));
        app = address(new FishCollectorUser(fishcollector, fish));
        maintainer = address(new FishCollectorUser(fishcollector, fish));
        fish.mint(app, initialBalanceApp);
        fish.mint(maintainer, initialBalanceController);
    }

    function approveAndDeposit(
        address _app,
        address _controller,
        uint256 _amount
    ) public {
        FishCollectorUser(_app).registerMaintainer(_controller);
        TokenUser(app).doApprove(address(fishcollector), _amount);
        emit log_named_uint("amount:", _amount);
        FishCollectorUser(app).deposit(_amount);
    }

    function testSetup() public {
        assertEq(fish.balanceOf(address(this)), initialBalanceThis);
        assertEq(fish.balanceOf(app), initialBalanceApp);
        assertEq(fish.balanceOf(maintainer), initialBalanceController);
        assertEq(fish.balanceOf(address(fishcollector)), 0);
    }

    function testDeposit() public {
        approveAndDeposit(app, maintainer, 100 ether);
        assertEq(fishcollector.balanceOf(app), 5 ether);
        assertEq(fishcollector.balanceOf(sink), 95 ether);
        assertEq(fish.balanceOf(address(fishcollector)), 100 ether);
    }

    function testFuzzDeposit(uint64 _amount) public {
        fish.mint(app, _amount);
        fish.mint(maintainer, _amount);
        if (_amount > 0) {
            approveAndDeposit(app, maintainer, _amount);
        }
    }

    function testFailDepositZero() public {
        approveAndDeposit(app, maintainer, 0);
    }

    function testDepositWithHigherRate() public {
        fishcollector.setRate(700);
        approveAndDeposit(app, maintainer, 100 ether);
        assertEq(fishcollector.balanceOf(app), 7 ether);
        assertEq(fishcollector.balanceOf(sink), 93 ether);
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

    function testFailWhenRegisterMaintaineringOwnerAsApp() public {
        FishCollectorUser(maintainer).registerMaintainer(maintainer);
    }

    function testFailWhenRegisterMaintaineringControllerAsApp() public {
        FishCollectorUser(maintainer).registerMaintainer(maintainer);
    }

    function testFailWhenRegisterMaintaineringNullAddressAsController() public {
        FishCollectorUser(maintainer).registerMaintainer(address(0));
    }

    function testFailWhenDepositerIsOwner() public {
        uint256 _amount = 100 ether;
        fishcollector.registerMaintainer(maintainer);
        fish.approve(address(fishcollector), _amount);
        fishcollector.deposit(_amount);
    }

    function testFailWithdrawalController() public {
        FishCollectorUser(maintainer).doWithdraw(app);
    }

    function testWithdrawController() public {
        approveAndDeposit(app, maintainer, 100 ether);
        assertEq(fishcollector.balanceOf(app), 5 ether);
        FishCollectorUser(maintainer).doWithdraw(app);
        assertEq(fishcollector.balanceOf(app), 0);
        assertEq(
            fish.balanceOf(maintainer),
            initialBalanceController + 5 ether
        );
    }

    function testWithdrawControllerFuzz(uint32 _amount_) public {
        uint256 _amount = uint256(_amount_);
        fish.mint(app, _amount);
        fish.mint(maintainer, _amount);
        uint256 initBal = fish.balanceOf(maintainer);
        uint256 _withdrawal = ((_amount * 500) / 10000);
        if (_withdrawal == 0) return;
        approveAndDeposit(app, maintainer, _amount);
        assertEq(fishcollector.balanceOf(app), _withdrawal);
        FishCollectorUser(maintainer).doWithdraw(app);
        assertEq(fishcollector.balanceOf(app), 0);
        assertEq(fish.balanceOf(maintainer), initBal + _withdrawal);
    }

    function testMultipleAppsCanBeLinkedToASingleController() public {
        uint256 num = 100;

        address[] memory _addrs = new address[](num);
        for (uint32 _i = 0; _i < num; _i++) {
            _addrs[_i] = (address(new FishCollectorUser(fishcollector, fish)));
            fish.mint(_addrs[_i], 100 ether);
            FishCollectorUser(_addrs[_i]).registerMaintainer(maintainer);
            TokenUser(_addrs[_i]).doApprove(address(fishcollector), 100 ether);
            FishCollectorUser(_addrs[_i]).deposit(100 ether);
            assertEq(fishcollector.balanceOf(_addrs[_i]), 5 ether);
        }
    }
}
