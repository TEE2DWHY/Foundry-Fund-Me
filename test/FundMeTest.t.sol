// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundeMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        DeployFundeMe deployFundeMe = new DeployFundeMe(); // we easily deploy the contract here and test it
        fundMe = deployFundeMe.run();
    }

    function testMinimumDollarisFive() public view {
        uint256 expected = 50 * 1e18;
        uint256 actual = fundMe.MINIMUM_USD();
        assertEq(actual, expected);
    }

    function testOwnerisMsgSender() public view {
        address expected = address(msg.sender);
        address actual = fundMe.i_owner();
        assertEq(actual, expected);
    }

    function testGetPriceConverterVersion() public view {
        // run => forge test --match-test "testGetPriceConverterVersion" -vvv --fork-url $RPC_URL (to simulate on sepolia)
        uint256 expectedVersion = 4;
        console.log(fundMe.getVersion());
        assertEq(fundMe.getVersion(), expectedVersion);
    }

    function testIfAmountFundedMatches() public {
        uint256 expected = 100000000000000000;
        fundMe.fund{value: expected}();
        uint256 actual = fundMe.getFundedAmount(address(this));
        assertEq(expected, actual);
    }
}
