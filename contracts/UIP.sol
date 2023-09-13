// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./interfaces/IUIP.sol";

import "./libraries/TRC25.sol";

/**
 * @title UIP
 * @notice UIP is decentralized stablecoin
 */
contract UIP is TRC25, IUIP {
    // for free gas features
    address immutable private TOMOZ_ISSUER;

    struct Factory {
        bool isActive;
        uint256 limitMintAmountPerDay;
        uint256 limitBurnAmountPerDay;
        mapping(uint256 => uint256) mintPerDays;
        mapping(uint256 => uint256) burnPerDays;
    }

    event MintFromFactory(address factory, address receiver, uint256 amount);
    event BurnFromFactory(address factory, address from, uint256 amount);
    
    mapping(address => Factory) private _factories;

    constructor(string memory name, string memory symbol, uint8 decimals) TRC25(name, symbol, decimals) {
        TOMOZ_ISSUER = address(0);
    }

    function _estimateFee(uint256) internal pure override returns (uint256) {
        // check with tomoz issuer, otherwise the fee for transfer will be 0.1 USDZ
        return (1 ether / 10);
    }

    /**
     * @notice return the day
     */
    function _getDay() internal view returns (uint256) {
        return (block.timestamp % 1 days);
    }

    /**
     * @notice Mint UIP by factory
     * @param receiver receiver address
     * @param amount amount to mint
     */
    function mint(address receiver, uint256 amount) external override {
        Factory storage factory = _factories[msg.sender];
        require(factory.isActive, "UIP: Caller is not minter");

        uint256 day = _getDay();
        uint256 todayMinted = factory.mintPerDays[day];
        require(factory.limitMintAmountPerDay == 0 || todayMinted + amount <= factory.limitMintAmountPerDay, "UIP: reach limitation mint per days");

        _mint(receiver, amount);

        factory.mintPerDays[day] += amount;

        emit MintFromFactory(msg.sender, receiver, amount);
    }

    /**
     * @notice burn UIP by factory
     * @param from burn from address
     * @param amount amount to burn
     */
    function burn(address from, uint256 amount) external override {
        Factory storage factory = _factories[msg.sender];
        require(factory.isActive, "UIP: Caller is not burner");

        uint256 day = _getDay();
        uint256 todayBurned = factory.burnPerDays[day];
        require(factory.limitBurnAmountPerDay == 0 || todayBurned + amount <= factory.limitBurnAmountPerDay, "UIP: reach limitation burn per days");

        _burn(from, amount);

        factory.burnPerDays[day] += amount;

        emit BurnFromFactory(msg.sender, from, amount);
    }

    /**
     * @notice Add new factory
     * @param factoryAddress address of factory
     * @param limitMintPerDay limit mint amount per day
     * @param limitBurnPerDay limit burn amount per day
     */
    function addFactory(address factoryAddress, uint256 limitMintPerDay, uint256 limitBurnPerDay) external onlyOwner {
        Factory storage factory = _factories[factoryAddress];
        require(!factory.isActive, "UIP: Actively factory");

        factory.isActive = true;
        factory.limitMintAmountPerDay = limitMintPerDay;
        factory.limitBurnAmountPerDay = limitBurnPerDay;
    }

    /**
     * @notice Remove factory
     * @param factoryAddress address of factory
     */
    function removeFactory(address factoryAddress) external onlyOwner {
        Factory storage factory = _factories[factoryAddress];
        require(factory.isActive, "UIP: Not active factory");

        delete _factories[factoryAddress];
    }

    /**
     * @notice Set parameter for factory
     * @param factoryAddress address of factory
     * @param limitMintPerDay limit mint amount per day
     * @param limitBurnPerDay limit burn amount per day
     */
    function setFactory(address factoryAddress, uint256 limitMintPerDay, uint256 limitBurnPerDay) external onlyOwner {
        Factory storage factory = _factories[factoryAddress];
        require(factory.isActive, "UIP: Not active factory");

        factory.limitMintAmountPerDay = limitMintPerDay;
        factory.limitBurnAmountPerDay = limitBurnPerDay;
    }
}
