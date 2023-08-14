// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";

contract DeployFundMe is Script {
    // function run() external {
    //     vm.startBroadcast();
    //     new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     vm.stopBroadcast();
    // }

    // if we change anything from script, we also have to change in test
    // so we can update above and import deployFundMe in test first and then

    // function run() external returns (FundMe) {
    //     vm.startBroadcast();
    //     FundMe fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     vm.stopBroadcast();
    //     return fundMe;
    // }
    // also update setup from test

    // Mock
    // Instead of calling alchemy for every single test and waste resources
    // we can use mock to deploy fake local price feed

    // now to use helper config and to make deploying more dynamic for different chain
    function run() external returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        //before broadcast is not a real transaction so less gas
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
