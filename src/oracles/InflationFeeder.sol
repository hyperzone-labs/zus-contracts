// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IInflationFeeder.sol";

contract InflationFeeder is IInflationFeeder {
    function getCurrentInflationRate() external view override returns (uint256, uint8) {
        return (1, 1);
    }
}
