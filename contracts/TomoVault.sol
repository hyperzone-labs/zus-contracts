// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;

import "./interfaces/IPriceFeeder.sol";

contract TomoVault {
    address immutable private STAKE_CONTRACT_ADDRESS;
    address immutable private ZUSD_ADDRESS;

    address private _priceFeed;

    struct UserInfo {
        uint256 balanceDeposited;
        uint256 balanceMinted;
    }

    constructor(address stakeContractAddress, address zUSDAddress) {
        STAKE_CONTRACT_ADDRESS = stakeContractAddress;
        ZUSD_ADDRESS = zUSDAddress;
    }

    function deposit() external payable {
    }

    function mint(uint256 amount) external {
        (uint256 price, uint8 decimals) = IPriceFeeder(_priceFeed).getPrice();
    }

    function burnAndWithdraw() external payable {

    }

    function liquilidate() external {

    }
}