// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IVaultManager.sol";

contract VaultManager is IVaultManager {
    using SafeERC20 for IERC20;

    function receiveMoney(address token, uint256 amount) external override {}

    function withdrawMoney(address token, address receiver, uint256 amount) external override {
        IERC20(token).safeTransfer(receiver, amount);
    }
}
