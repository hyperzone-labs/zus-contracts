// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;

interface IZUSD {
    function mint(address receiver, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}