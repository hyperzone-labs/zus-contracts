// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IVaultManagerCallback {
    function receiveMoney(address token, uint256 amount) external;
}
