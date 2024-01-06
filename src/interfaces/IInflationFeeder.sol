// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IInflationFeeder {
    function getCurrentInflationRate() external view returns (uint256, uint8);
}
