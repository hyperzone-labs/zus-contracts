// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IInflationFeeder.sol";
import "../libraries/Operators.sol";

contract InflationFeeder is IInflationFeeder, Ownable, Operator {
    uint256 currentInflationRate;

    constructor() Ownable(msg.sender) {
    }

    function getCurrentInflationRate() external view override returns (uint256, uint8) {
        return (currentInflationRate, 18);
    }

    function setOperator(address operator, bool isActive) external override onlyOwner() {
        _setOperator(operator, isActive);
    }
    
    function updateInflationRate(uint256 newInflationRate) external onlyOperator() {
        currentInflationRate = newInflationRate;
    }
}
