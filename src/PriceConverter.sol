// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// terminal - forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit
// then update foundry.toml
library PriceConverter {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI ( get the price from contract, we only need price) we use Interface
        // Interface is function declerations that we can use
        // interact with the contract that is storing the price of eth
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x694AA1769357215DE4FAC081bf1f309aDC325306
        // );
        (, int256 price, , , ) = priceFeed.latestRoundData();
        // this ignores other values from latestRoundData() and only gives us price.
        //price of ETH in USD
        // 2000.0000000
        // msg.value have 18 decimal and price have 8, so we do this and also cast it into uint256
        return uint256(price * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // 1 ETH?
        // 2000_0000000000000000
        uint256 ethPrice = getPrice(priceFeed);
        // (2000_0000000000000000 * 1_00000000000000000) 1e18
        // $2000 = 1ETH
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        return ethAmountInUsd;
    }

    function getVersion() internal view returns (uint256) {
        return
            AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
                .version();
        // return s_priceFeed.version();
    }
}
