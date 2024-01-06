// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IInflationFeeder {
    function getCurrentInflationRate() external view returns(uint256, uint8);
}