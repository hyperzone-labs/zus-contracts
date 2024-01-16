// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IFactoryCallback {
    function mintCallback(
        address stablecoin,
        uint256 stablecoinAmount,
        uint256 zipAmount,
        uint256 zusAmount,
        bytes memory data
    ) external returns (bytes4);

    function redeemCallback(address stablecoin, uint256 stablecoinAmount, uint256 zipAmount, uint256 zusAmount, bytes memory data) external returns (bytes4);
}
