// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Fishcollector is Ownable {
    using Counters for Counters.Counter;
    using SafeERC20 for IERC20;

    uint16 private constant MAX_RATE = 1000;
    uint16 rate = 500;
    address currency;
    address sinkAddress;

    mapping(address => uint256) balances;
    mapping(address => address) controllers;

    constructor(address _sinkAddress, address _currency) {
        sinkAddress = _sinkAddress;
        currency = _currency;
    }

    function setRate(uint16 _rate) public onlyOwner {
        require(_rate < MAX_RATE, "Rate must be less than 10%");
        rate = _rate;
    }

    function register(address _app, address _controller) public onlyOwner {
        require(_app != _controller, "App cannot be controller");
        require(_app != owner(), "App cannot be owner");
        require(_app != address(0), "App cannot be null address");
        require(_controller != address(0), "App cannot be null address");
        controllers[_app] = _controller;
    }

    function calculateSplit(uint256 _amount)
        internal
        view
        returns (uint256, uint256)
    {
        return ((_amount * rate) / 10000, (_amount * (10000 - rate)) / 10000);
    }

    function balanceOf(address _controller) public view returns (uint256) {
        return balances[_controller];
    }

    function balanceOfApp(address _application) public view returns (uint256) {
        return balances[controllers[_application]];
    }

    function deposit(uint256 _amount) public {
        require(_amount > 0, "Amount must be greater than 0");

        require(msg.sender != sinkAddress, "multisig cannot be a depositor");
        require(
            address(msg.sender) != address(owner()),
            "owner cannot be a depositor"
        );
        require(
            controllers[msg.sender] != address(0),
            "Only registered applications can call deposit"
        );
        require(
            IERC20(currency).allowance(address(msg.sender), address(this)) >=
                _amount,
            "Please ensure token allowance has been set to be greater than the amount"
        );

        (uint256 _reward, uint256 _main) = calculateSplit(_amount);

        balances[sinkAddress] += _main;
        balances[controllers[msg.sender]] += _reward;

        IERC20(currency).safeTransferFrom(msg.sender, address(this), _amount);
    }

    function withdrawal() public {
        require(balances[msg.sender] > 0, "No balance available to withdraw");

        IERC20(currency).safeTransfer(msg.sender, balances[msg.sender]);
    }
}
