// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFactoryCallback {
    function mintCallback(address stablecoin, uint256 amountStablecoin, uint256 amountZIP, uint256 amountZUS, bytes memory data) external returns(bytes4);
    function burnCallback() external returns(bytes4);
}