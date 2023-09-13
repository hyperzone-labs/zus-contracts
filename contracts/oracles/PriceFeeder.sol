// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IPriceFeeder.sol";

contract PriceFeeder is Ownable, IPriceFeeder {
    uint256 _price;
    uint8 _decimals;

    constructor() {
        _decimals = 8;
    }

    function feedData(uint256 price) external onlyOwner {
        _price = price;
    }

    function getPrice() external view override returns(uint256, uint8) {
        return (_price, _decimals);
    }
}