import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { PriceFeeder, TomoBaseFactory, ZUSD } from "../typechain-types";

describe("TOMO Base Factory", () => {
    let ZUSD: ZUSD
    let tomoBaseFactory: TomoBaseFactory
    let priceFeeder: PriceFeeder

    before(async () => {
        const ZUSDFactory = await ethers.getContractFactory("ZUSD")
        ZUSD = await ZUSDFactory.deploy("Ziphius USD", "ZUSD", 18)

        const PriceFeederFactory = await ethers.getContractFactory("PriceFeeder")
        priceFeeder = await PriceFeederFactory.deploy();

        const TomoBaseFactory = await ethers.getContractFactory("TomoBaseFactory")
        tomoBaseFactory = await TomoBaseFactory.deploy(ZUSD.getAddress(), ZUSD.getAddress(), priceFeeder.getAddress())

        priceFeeder.feedData(1e8);
    })

    it("Already true", async () => {
        const price = await priceFeeder.getPrice()
        console.log(price)
    })
});
