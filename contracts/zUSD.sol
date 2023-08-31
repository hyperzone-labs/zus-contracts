// SPDX-License-Identifier: MIT
pragma solidity =0.7.0;

import "./libraries/TRC25.sol";

contract ZUSD is TRC25 {
    address immutable private TOMOZ_ISSUER;

    struct VaultInfo {
        bool isActive;
        uint256 limitMintAmountPerDay;
        uint256 limitBurnAmountPerDay;
        mapping(uint256 => uint256) mintPerDays;
        mapping(uint256 => uint256) burnPerDays;
    }
    
    mapping(address => VaultInfo) private _vaultInfos;

    constructor(string memory name, string memory symbol, uint8 decimals) TRC25(name, symbol, decimals) {
        TOMOZ_ISSUER = address(0);
    }

    function _estimateFee(uint256) internal view override returns (uint256) {
        return (1 ether / 10);
    }
}