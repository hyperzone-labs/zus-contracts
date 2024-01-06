// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IFactory {
    enum Mode {
        DEPOSIT_MODE,
        ANTI_INFLATION_MODE
    }

    event MigrateMode(Mode newMode);

    // function migrateMode() external;
    // function mint() external;
    // function getRedeemRate() external view returns(uint256);
    // function getMode() external view returns(ZIPMode);
    // function getAccumulateInflationRate() external view returns(int256);
}
