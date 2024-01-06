// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/IFactory.sol";
import "./interfaces/IFactoryCallback.sol";
import "./interfaces/IMintBurnERC20.sol";

/**
 * @title Factory contract
 * @author Terry
 * @dev Factory
 */
contract Factory is IFactory, Ownable {
    using SafeERC20 for IMintBurnERC20;

    IMintBurnERC20 public immutable ZIP_TOKEN;
    IMintBurnERC20 public immutable ZUS_TOKEN;

    Mode private _mode;
    address private _vaultManager;
    address private _inflationRateFeeder;
    uint256 private _startAntiInflationModeTimestamp;

    // We do some awesome math
    int256 private _accumulateInflationRate;

    mapping(address => bool) private _backedStablecoin;

    constructor(address zipToken, address zusToken, address vaultManager, address inflationRateFeeder)
        Ownable(msg.sender)
    {
        ZIP_TOKEN = IMintBurnERC20(zipToken);
        ZUS_TOKEN = IMintBurnERC20(zusToken);

        _mode = Mode.DEPOSIT_MODE;
        _vaultManager = vaultManager;
    }

    modifier validBackedStablecoin(address stablecoin) {
        require(_backedStablecoin[stablecoin], "Invalid stablecoin");
        _;
    }

    function accumulateInflation() external {}

    /**
     * @dev Migrate mode fromm deposit mode -> anti inflation mode
     */
    function migrateMode() external onlyOwner {
        require(_mode == Mode.DEPOSIT_MODE, "ZIPFactory: Invalid mode");
        _mode = Mode.ANTI_INFLATION_MODE;

        emit MigrateMode(_mode);
    }

    /**
     * @dev Mint new ZUS token
     */
    function mint(address stablecoin, uint256 amountStablecoin, address receiver, bytes memory data)
        external
        validBackedStablecoin(stablecoin)
        returns (uint256 zipAmount, uint256 zusAmount)
    {
        if (_mode == Mode.DEPOSIT_MODE) {
            // convert ZUS 1-1 with stablecoin
            zusAmount = amountStablecoin;

            ZIP_TOKEN.safeTransferFrom(msg.sender, _vaultManager, amountStablecoin);
            ZUS_TOKEN.mint(receiver, zusAmount);

            zipAmount = 0;
            zusAmount = amountStablecoin;
        } else if (_mode == Mode.ANTI_INFLATION_MODE) {
            // TODO: Anti inflation handler
        } else {
            revert();
        }

        if (data.length > 0) {
            bytes4 magicValue =
                IFactoryCallback(receiver).mintCallback(stablecoin, amountStablecoin, zipAmount, zusAmount, data);
            require(magicValue == IFactoryCallback.mintCallback.selector, "Invalid magic value");
        }
    }

    /**
     * @dev Redeem ZUS token
     */
    function redeem(address stablecoin, uint256 amountZUS)
        external
        validBackedStablecoin(stablecoin)
        returns (uint256 zipAmount)
    {
        if (_mode == Mode.DEPOSIT_MODE) {}
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
