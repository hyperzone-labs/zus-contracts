// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

import "forge-std/console.sol";

import "../src/MintBurnToken.sol";

contract MintBurnTokenTest is Test {
    MintBurnToken token;

    address owner;
    uint256 ownerKey;

    address factory;
    uint256 factoryKey;

    function setUp() external {
        ownerKey = uint256(keccak256("owner"));
        owner = vm.addr(ownerKey);

        factoryKey = uint256(keccak256("factory"));
        factory = vm.addr(factoryKey);

        vm.startPrank(owner);
        token = new MintBurnToken("Test Token", "TT");
        vm.stopPrank();
    }

    function testSetFactory() public {
        vm.prank(owner);
        token.setFactoryStatus(factory, true);
    }

    function testFactoryMintToken() public {
        vm.prank(owner);
        token.setFactoryStatus(factory, true);

        vm.prank(factory);
        token.mint(factory, 100);
    }

    function testFactoryBurnToken() public {
        vm.prank(owner);
        token.setFactoryStatus(factory, true);

        vm.prank(factory);
        token.mint(factory, 100);

        vm.prank(factory);
        token.burn(factory, 100);
    }
}
