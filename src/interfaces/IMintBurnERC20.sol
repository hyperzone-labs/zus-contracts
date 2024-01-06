// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMintBurnERC20 is IERC20 {
    function mint(address receiver, uint256 amount) external;
    function burn(address from, uint256 amount) external;
}
