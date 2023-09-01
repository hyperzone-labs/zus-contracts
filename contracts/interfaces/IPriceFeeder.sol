// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;

interface IPriceFeeder {
    function getPrice() external view returns(uint256, uint8);
}