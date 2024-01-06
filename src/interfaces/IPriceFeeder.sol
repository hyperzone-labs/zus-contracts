// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IPriceFeeder {
    function getPrice() external view returns (uint256, uint8);
}
