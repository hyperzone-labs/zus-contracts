import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { TomoBaseFactory, ZUSD } from "../typechain-types";

describe("TOMO Base Factory", () => {
    let ZUSD: ZUSD
    let tomoBaseFactory: TomoBaseFactory
    before(async () => {
        const ZUSDFactory = await ethers.getContractFactory("ZUSD")
        ZUSD = await ZUSDFactory.deploy("Ziphius USD", "ZUSD", 18)

        const TomoBaseFactory = await ethers.getContractFactory("TomoBaseFactory")
        tomoBaseFactory = await TomoBaseFactory.deploy(ZUSD.getAddress(), ZUSD.getAddress())
    })

    it("Already true", async () => {
        console.log(ZUSD)
        console.log(tomoBaseFactory)
    })
});
