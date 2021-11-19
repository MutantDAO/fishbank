// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "./Fishbank.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract FishDepositor {
    using SafeERC20 for IERC20;

    address private fishBank;

    constructor(address _fishBank, address _maintainer) {
        require(_fishBank != address(0), "Cannnot be the null address");
        fishBank = _fishBank;

        Fishbank(fishBank).registerMaintainer(_maintainer);
    }

    function _doFishDeposit(uint256 _amount) internal {
        IERC20(Fishbank(fishBank).currency()).safeApprove(fishBank, _amount);
        Fishbank(fishBank).deposit(_amount);
    }
}
