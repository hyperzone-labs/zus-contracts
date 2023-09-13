// SPDX-License-Identifier: MIT
pragma solidity =0.8.0;

import "../../interfaces/IPriceFeeder.sol";
import "../../interfaces/IUIP.sol";

/**
 * @title TomoBaseFactory
 * @notice Tomo base factory is TOMO base collateral vault to mint UIP
 */
contract TomoBaseFactory {
    address immutable public STAKE_CONTRACT_ADDRESS;
    address immutable public UIP_ADDRESS;

    uint256 immutable public LIMIT_BORROW = 7000;
    uint256 immutable public RESERVE_PERCENT = 3000;
    uint256 immutable public LIQUIDATION_THRESHOLD = 7500;

    address private _priceFeed;

    uint256 private _totalDeposited;

    struct UserVault {
        uint256 amountDeposited;
        uint256 amountMinted;
    }

    mapping(address => UserVault) private _userVaults;

    constructor(address stakeContractAddress, address uipAddress, address priceFeeder) {
        STAKE_CONTRACT_ADDRESS = stakeContractAddress;
        UIP_ADDRESS = uipAddress;
        _priceFeed = priceFeeder;
    }

    function _heathFactor(address user) internal view returns(uint256) {
        UserVault memory userVault = _userVaults[user];
        (uint256 price, uint8 decimals) = IPriceFeeder(_priceFeed).getPrice();

        uint256 amountDepositInUSD = userVault.amountDeposited * price / decimals;

        if (userVault.amountMinted == 0) {
            return 2**256 - 1;
        }

        return (amountDepositInUSD * LIQUIDATION_THRESHOLD) / (userVault.amountMinted * 10000);
    }
    
    function heathFactor(address user) public view returns(uint256) {
        return _heathFactor(user);
    }

    function _maximunMintAmount(address user) internal view returns(uint256) {
        UserVault memory userVault = _userVaults[user];
        (uint256 price, uint8 decimals) = IPriceFeeder(_priceFeed).getPrice();

        uint256 amountDepositInUSD = userVault.amountDeposited * price / decimals;

        return (amountDepositInUSD * LIMIT_BORROW / 10000) - userVault.amountMinted;
    }
    
    function deposit() external payable {
        UserVault storage userVault = _userVaults[msg.sender];
        userVault.amountDeposited += msg.value;

        _totalDeposited += msg.value;

        // TODO: deposit (1 - RESERVE_PERCENT / 1000) * msg.value to tomo stake contract
    }

    function mint(uint256 amount) external {
        require(amount > 0 && amount < _maximunMintAmount(msg.sender), "UIP: Invalid amount");

        UserVault storage userVault = _userVaults[msg.sender];
        userVault.amountMinted += amount;

        require(_heathFactor(msg.sender) > 1, "UIP: reach liquidation");

        IUIP(UIP_ADDRESS).mint(msg.sender, amount);
    }

    function burn(uint256 amount) external {
        require(amount > 0, "UIP: Invalid amount");

        UserVault storage userVault = _userVaults[msg.sender];
        userVault.amountMinted -= amount;

        IUIP(UIP_ADDRESS).burn(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        require(amount > 0, "UIP: Invalid amount");

        UserVault storage userVault = _userVaults[msg.sender];
        userVault.amountDeposited -= amount;

        require(_heathFactor(msg.sender) > 1, "UIP: Reach liquidation");

        _totalDeposited -= amount;

        // TODO: withdraw TOMO from staking contract

        (bool success,) = address(msg.sender).call{value: amount}("");
        require(success, "TomoBaseFactory: Transfer fail");
    }

    function liquidate(address user, uint256 payAmount) external {
        require(_heathFactor(user) <= 1, "UIP: Still safe");

        UserVault storage userVault = _userVaults[user];
        require(payAmount <= userVault.amountMinted, "UIP: Invalid amount");

        IUIP(UIP_ADDRESS).burn(msg.sender, payAmount);

        uint256 returnAmount = payAmount * userVault.amountDeposited / userVault.amountMinted;
        userVault.amountDeposited -= returnAmount;
        userVault.amountDeposited -= payAmount;

        (bool success,) = address(msg.sender).call{value: returnAmount}("");
        require(success, "TomoBaseFactory: Transfer fail");
    }
}
