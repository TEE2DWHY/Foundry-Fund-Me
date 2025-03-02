// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

//Every test should start with the word test so that the test runner can identify it

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 AMOUN_TO_FUND = 0.1 ether;
    uint256 STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // fund ether to the user for testing
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
        vm.prank(USER);
        uint256 expected = AMOUN_TO_FUND;
        fundMe.fund{value: expected}();
        uint256 actual = fundMe.getFundedAmount(USER);
        assertEq(expected, actual);
    }

    function testFundingShouldFailWithoutEnoughAmount() public {
        vm.expectRevert();
        fundMe.fund{value: 10000}();
    }

    function testIfFunderGetsAddedToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: AMOUN_TO_FUND}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        uint256 prevContractBalance = fundMe.getContractBalance();
        address owner = fundMe.i_owner();
        uint256 prevOwnerBalance = address(owner).balance;

        uint256 gasLeft = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(owner); // every transaction below this line will be executed as the owner
        fundMe.withdraw();
        uint256 gasEnd = gasleft();

        uint256 gasUsed = (gasLeft - gasEnd) * tx.gasprice;
        console.log("Gas used: ", gasUsed);

        uint256 newOwnerBalance = address(owner).balance;
        assertEq(prevOwnerBalance + prevContractBalance, newOwnerBalance);
        uint256 newContractBalance = fundMe.getContractBalance();
        assertEq(newContractBalance, 0);
    }

    function testWithdrawalMultipleMultipleFunders() public {
        uint160 totalFunders = 10;
        uint160 startingFunderIndex = 1; // thi uint160 has similar byte as an address
        address owner = fundMe.i_owner();
        for (uint160 i = startingFunderIndex; i < totalFunders; i++) {
            hoax(address(i), AMOUN_TO_FUND); // fund ether to the user for testing
            fundMe.fund{value: AMOUN_TO_FUND}();
        }
        uint256 prevOwnerBalance = address(owner).balance;
        uint256 prevContractBalance = fundMe.getContractBalance();
        vm.startPrank(owner); // start pranking the owner
        fundMe.withdraw();
        vm.stopPrank();
        uint256 newOwnerBalance = address(owner).balance;
        uint256 newContractBalance = fundMe.getContractBalance();
        assertEq(prevContractBalance + prevOwnerBalance, newOwnerBalance);
        address[] memory funders = fundMe.getFunders();
        assertEq(newContractBalance, 0); // contract balance should be zero
        assertEq(funders.length, 0);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: AMOUN_TO_FUND}();
        _;
    }
}
