// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/IMintBurnERC20.sol";

/**
 * @title MintBurnToken
 * @notice Decentralized money
 */
contract MintBurnToken is IMintBurnERC20, ERC20, Ownable {
    event SetFactory(address factory, bool status);
    event MintFromFactory(address factory, address receiver, uint256 amount);
    event BurnFromFactory(address factory, address from, uint256 amount);

    mapping(address => bool) private _activeFactories;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    modifier onlyFromFactory() {
        require(_activeFactories[msg.sender], "Caller is not factory");
        _;
    }

    /**
     * @notice Mint token by factory
     * @param receiver receiver address
     * @param amount amount to mint
     */
    function mint(address receiver, uint256 amount) external override onlyFromFactory {
        _mint(receiver, amount);
        emit MintFromFactory(msg.sender, receiver, amount);
    }

    /**
     * @notice Burn token by factory
     * @param from burn from address
     * @param amount amount to burn
     */
    function burn(address from, uint256 amount) external override onlyFromFactory {
        _burn(from, amount);
        emit BurnFromFactory(msg.sender, from, amount);
    }

    /**
     * @notice Set factory status
     * @param factoryAddress address of factory
     * @param isActive status of factory
     */
    function setFactoryStatus(address factoryAddress, bool isActive) external onlyOwner {
        _activeFactories[factoryAddress] = isActive;

        emit SetFactory(factoryAddress, isActive);
    }
}
