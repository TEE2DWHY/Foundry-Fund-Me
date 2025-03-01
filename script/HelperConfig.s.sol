//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// A pure function =>  A function that performs calculations or returns fixed values based on the arguments provided.
//  Pure functions do not read from or write to the blockchain state
// A view function => A function that reads from the blockchain state but does not write to it. they can access state variables or other contract functions.

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;
    uint256 constant SEPOLIA_CHAIN_ID = 11155111;
    uint8 decimals = 8;
    int256 initialAnswer = 1e17;

    struct NetworkConfig {
        address priceFeedAddress;
    }

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeedAddress: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeedAddress != address(0)) {
            // this helps to not deploy a new contract if the address is already set.
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggreagtor = new MockV3Aggregator(
            decimals,
            initialAnswer
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeedAddress: address(mockV3Aggreagtor)
        });
        return anvilConfig;
    }
}
