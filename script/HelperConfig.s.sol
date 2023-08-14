//1. Deploy mocks where we are on local anvil chain
// keep track of contract address across different chain
// Sepolia ETH/USD
// Mainnet ETH/USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// is Scipt gives vm variable
contract HelperConfig is Script {
    // if we are on a local anvil, we deploy mocks
    // otherwise, grab the existing address from live network

    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        //price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        //price feed address
        // anvil is different bcz we need to use mocks bcz contracts dnt exists
        // as compared to live networks

        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }
        // if we dont do the above if, it will create a new price feed
        // but if we have already deployed one we can use it again
        // but checking is the address is not 0
        // means we have deployed it before and we get the active network

        //1. Deploy mock (fake/dummy contract)
        //2. return mock address

        vm.startBroadcast();
        // here we will deploy our own price feed
        // we create a mock aggregator ( test-> mocks->MockV3..)
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
