// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

interface IUIP {
    function mint(address receiver, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
