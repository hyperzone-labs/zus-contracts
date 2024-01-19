// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IVaultManager {
    function receiveMoney(address token, uint256 amount) external;
    function withdrawMoney(address token, address receiver, uint256 amount) external;
}
