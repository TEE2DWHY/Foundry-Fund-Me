// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "./DeployFundMe.s.sol";

contract FundFundMe is Script {
    function run() external {
        address USER = makeAddr("user");
        FundMe fundMe;
        console.log("Interacting with the FundMe contract...");
        vm.deal(USER, 100 ether);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        console.log("Funding Contract");

        vm.startBroadcast(USER);
        fundMe.fund{value: 0.1 ether}();
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    // to execute this run => forge script script/Interactions.s.sol --tc WithdrawFundMe
    function run() external {
        FundMe fundMe;
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        address owner = fundMe.i_owner();

        address USER = makeAddr("user");
        vm.deal(USER, 10 ether);
        console.log("Funding the contract");

        vm.startPrank(USER);
        fundMe.fund{value: 0.1 ether}();
        vm.stopPrank();

        uint256 contractBalanceBefore = fundMe.getContractBalance();
        console.log(
            "Contract balance before withdraw: ",
            contractBalanceBefore
        );

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        uint256 contractBalanceAfter = fundMe.getContractBalance();
        console.log("Contract balance after withdraw: ", contractBalanceAfter);
    }
}
