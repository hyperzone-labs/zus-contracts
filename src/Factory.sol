// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IFactoryCallback.sol";
import "./interfaces/IMintBurnERC20.sol";
import "./interfaces/IVaultManager.sol";
import "./interfaces/IPriceFeeder.sol";
import "./interfaces/IInflationFeeder.sol";

import "./libraries/Operators.sol";

/**
 * @title Factory contract
 * @author @imterryyy
 * @dev Factory
 */
contract Factory is IFactory, Ownable, Operator {
    using SafeERC20 for IMintBurnERC20;

    IMintBurnERC20 public immutable ZIP_TOKEN;
    IMintBurnERC20 public immutable ZUS_TOKEN;

    uint8 private constant PRICE_CONFIG_DECIMALS = 18; // for convert price

    Mode private _mode;
    address private _vaultManager;
    address private _inflationRateFeeder;
    uint256 private _lastAccumulateTimestamp;

    // We do some awesome math
    int256 private _accumulateInflationRate; // 1e18 in decimals

    mapping(address => bool) private _backedStablecoin;
    mapping(address => address) private _oraclesZIPOnStablecoin;

    constructor(address zipToken, address zusToken, address vaultManager, address inflationRateFeeder)
        Ownable(msg.sender)
    {
        ZIP_TOKEN = IMintBurnERC20(zipToken);
        ZUS_TOKEN = IMintBurnERC20(zusToken);

        _mode = Mode.DEPOSIT_MODE;
        _vaultManager = vaultManager;
        _inflationRateFeeder = inflationRateFeeder;
    }

    modifier validBackedStablecoin(address stablecoin) {
        require(_backedStablecoin[stablecoin], "Invalid stablecoin");
        _;
    }

    function _convertStablecoinToZIP(address stablecoin, uint256 amountStablecoin) internal view returns(uint256) {
        (uint256 tokenPrice, uint8 priceDecimals) = IPriceFeeder(_oraclesZIPOnStablecoin[stablecoin]).getPrice();
        if(priceDecimals + 18 > PRICE_CONFIG_DECIMALS) {
            uint8 decs = priceDecimals + 18 - PRICE_CONFIG_DECIMALS;
            return amountStablecoin * 10**decs / tokenPrice;
        }
        if(priceDecimals + 18 < PRICE_CONFIG_DECIMALS) {
            uint8 decs = PRICE_CONFIG_DECIMALS - priceDecimals - 18;
            return amountStablecoin / 10**decs / tokenPrice;
        }
        return amountStablecoin / tokenPrice;
    }

    function setOperator(address operator, bool isActive) external override onlyOwner {
        _setOperator(operator, isActive);
    }

    /**
     * @dev Accumulate inflation
     */
    function accumulateInflation() external onlyOperator {
        require(_mode == Mode.ANTI_INFLATION_MODE, "Only anti inflation mode");

        // TODO: accumulate implement
        (uint256 currentInflationRate, uint8 inflationRateDecimals) = IInflationFeeder(_inflationRateFeeder).getCurrentInflationRate();
        _lastAccumulateTimestamp = block.timestamp;
    }

    /**
     * @dev Migrate mode fromm deposit mode -> anti inflation mode
     */
    function migrateMode() external onlyOwner {
        require(_mode == Mode.DEPOSIT_MODE, "Invalid mode");
        _mode = Mode.ANTI_INFLATION_MODE;

        emit MigrateMode(_mode);
    }

    /**
     * @dev Mint new ZUS token
     */
    function mint(address stablecoin, uint256 stablecoinAmount, address receiver, bytes memory data)
        external
        validBackedStablecoin(stablecoin)
        returns (uint256 zipAmount, uint256 zusAmount)
    {
        zusAmount = stablecoinAmount;

        // take stablecoin from sender
        ZIP_TOKEN.safeTransfer(_vaultManager, stablecoinAmount);
        // call to vault manager
        IVaultManager(_vaultManager).receiveMoney(stablecoin, stablecoinAmount);

        if (_mode == Mode.DEPOSIT_MODE) {
            zipAmount = 0;
        } else if (_mode == Mode.ANTI_INFLATION_MODE) {
            zipAmount = _convertStablecoinToZIP(stablecoin, (uint256(_accumulateInflationRate) - 1e18) * stablecoinAmount / 1e18);
        } else {
            revert();
        }

        ZUS_TOKEN.mint(receiver, zusAmount);

        if (data.length > 0) {
            bytes4 magicValue =
                IFactoryCallback(receiver).mintCallback(stablecoin, stablecoinAmount, zipAmount, zusAmount, data);
            require(magicValue == IFactoryCallback.mintCallback.selector, "Invalid magic value");
        }

        if (zipAmount > 0) {
            ZIP_TOKEN.burn(address(this), zipAmount);
        }
    }

    /**
     * @dev Redeem ZUS token
     */
    function redeem(address stablecoin, address receiver, uint256 zusAmount, bytes memory data)
        external
        validBackedStablecoin(stablecoin)
        returns (uint256 zipAmount, uint256 stablecoinAmount)
    {
        stablecoinAmount = zusAmount;
        // call to vault manager
        IVaultManager(_vaultManager).withdrawMoney(stablecoin, receiver, stablecoinAmount);

        if (_mode == Mode.DEPOSIT_MODE) {
            zipAmount = 0;
        } else {
            zipAmount = _convertStablecoinToZIP(stablecoin, (uint256(_accumulateInflationRate) - 1e18) * stablecoinAmount / 1e18);
        }

        if (zipAmount > 0) {
            ZIP_TOKEN.mint(receiver, zipAmount);
        }

        if (data.length > 0) {
            bytes4 magicValue =
                IFactoryCallback(receiver).redeemCallback(stablecoin, stablecoinAmount, zipAmount, zusAmount, data);
            require(magicValue == IFactoryCallback.mintCallback.selector, "Invalid magic value");
        }

        ZUS_TOKEN.burn(address(this), zusAmount);
    }

    /**
     * @dev Get current mode
     */
    function getMode() external view returns (Mode) {
        return _mode;
    }

    /**
     * @dev Get current redeem rate
     */
    function getRedeemRate() external view returns (uint256) {}

    /**
     * @dev Get current accumulate inflation rate
     */
    function getAccumulateInflationRate() external view returns (int256) {
        return _accumulateInflationRate;
    }
}
