//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundeMe is Script {
    address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() external returns (FundMe) {
        console.log("Deploying FundMe contract...");
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        console.log("FundMe deployed at: ", address(fundMe));
        return fundMe;
    }
}
