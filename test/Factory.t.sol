// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import "../src/Factory.sol";
import "../src/MintBurnToken.sol";
import "../src/VaultManager.sol";
import "../src/oracles/InflationFeeder.sol";
import "../src/oracles/PriceFeeder.sol";
import "../src/tests/MockERC20.sol";

contract FactorTest is Test {
    MockERC20 stablecoin;

    MintBurnToken zusToken;
    MintBurnToken zipToken;
    
    Factory factory;
    InflationFeeder inflationFeeder;
    PriceFeeder priceFeeder;

    VaultManager vaultManager;

    uint256 ownerKey = uint256(keccak256("owner"));
    address owner = vm.addr(ownerKey);

    uint256 userKey = uint256(keccak256("user"));
    address user = vm.addr(userKey);

    function setUp() external {
        vm.startPrank(owner);

        stablecoin = new MockERC20(1e18);

        zusToken = new MintBurnToken("ZUStable", "ZUS");
        zipToken = new MintBurnToken("Ziphius", "ZIP");
        inflationFeeder = new InflationFeeder();
        priceFeeder = new PriceFeeder();
        vaultManager = new VaultManager();
        factory = new Factory(address(zipToken), address(zusToken), address(vaultManager), address(inflationFeeder));

        factory.setOracle(address(stablecoin), address(priceFeeder));
        zusToken.setFactoryStatus(address(factory), true);
        zipToken.setFactoryStatus(address(factory), true);

        vm.stopPrank();
    }

    function testMintAndRedeemInDepositMode() public {
        vm.startPrank(user);
        uint256 amountStablecoin = 1e18;
        uint256 zusAmount = 1e18;
        stablecoin.mint(user, 1e18);

        stablecoin.transfer(address(factory), amountStablecoin);
        factory.mint(address(stablecoin), amountStablecoin, user, bytes(""));

        assertEq(stablecoin.balanceOf(address(vaultManager)), amountStablecoin, "Wrong vault manager balance is Stablecoin");
        assertEq(zusToken.totalSupply(), amountStablecoin, "Wrong total supply in ZUS");
        assertEq(zusToken.balanceOf(address(user)), zusAmount, "Wrong user balance in ZUS");

        zusToken.transfer(address(factory), amountStablecoin);
        factory.redeem(address(stablecoin), zusAmount, user, bytes(""));

        assertEq(zusToken.totalSupply(), 0, "Wrong total supply in ZUS");
        assertEq(zusToken.balanceOf(address(factory)), 0, "Wrong balance of factory in ZUS");
        assertEq(stablecoin.balanceOf(address(user)), amountStablecoin, "Wrong user balance in stablecoin");

        vm.stopPrank();
    }
}
