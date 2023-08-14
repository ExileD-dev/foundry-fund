// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

// Get funds from user
// withdraw funds
// set minimum funding amount in usd

// interface AggregatorV3Interface {
//     function decimals() external view returns (uint8);

//     function description() external view returns (string memory);

//     function version() external view returns (uint256);

//     function getRoundData(
//         uint80 _roundId
//     )
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );

//     function latestRoundData()
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );
// }

// Instead of pasting the whole interface of each contract we want to interact with,
// we can use github to directly import this interface.

//import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// we can create custom errors to save gas fee as well, sending string in require takes alot of gas

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    // attaching library to all uint256, so all uint256 have these library values
    //uint256 public myVal = 1;
    //uint256 public minimumUsd = 5;
    // now we need to update above var according to getConversionRate
    //uint256 public constant MINIMUM_USD = 5e18;
    uint256 public MINIMUM_USD = 5e18;
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;
    mapping(address funder => uint256 amountFunded)
        private s_addressToAmountFunded;

    //using constructors to disallow other people to call our withdraw function and save our money
    address private immutable i_owner;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // using constant and immutable allows us to make our code more gas effecient.
    //constant can be changed
    //immutable can only be updated once in the constructor
    //payable makes function accept native BC currency, makes button red.
    function fund() public payable {
        // Allow user to send $
        // Have minimum $ sent 5$
        // 1. how do we send ETH to this contract?
        // myVal = myVal+2;
        // msg.value = global of solidity, we can access transaction amount with it
        //require(msg.value > 1e18, "Didn't send enough ETH");
        // 1e18 = 1 ETH = 1000000000000000000 (wei) = 1 * 10 ** 18
        // require is like if else, we can ask for someting like (1 eth)
        // if the $ is not 1ETH, it reverts and display the message.
        // revert undo any actions that have been done, and send the remaining gas back
        // if reverts, myVal will stay 1 if the require reverts and the gas will be used.

        //require(msg.value > minimumUsd, "Didn't send enough ETH");
        // we need to use oracle chainlink to get the real world data(like 5 usd)
        // centralized oracles are point of failure because it will nullify smart contract/ BC
        // Chainlink is decentralized oracle network which we can use to get data.
        // helps us create hybrid smart contracts.

        // now using chainlink and conversions,

        //require(getConversionRate(msg.value) >= minimumUsd, "Didn't send enough ETH");
        // now that we have a library, we can use getConversionRate as this
        //getConversionRate is taking ethAmount as parameter, but when used in library,
        // msg.value is the first parameter which we dont need in paranthesis but before.
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "Didn't send enough ETH"
        );
        // need funders to keep records
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] =
            s_addressToAmountFunded[msg.sender] +
            msg.value;
    }

    // to make funcution more cheaper and gas effecient, we can use
    // storage variables
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
        // mostly, call is used to send eth currency tokens.
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Only Owner Can Withdraw");
        // for loop
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset array
        // instead of reseting each index, just reinitialize it.
        s_funders = new address[](0);
        // withdraw fund

        //transfer
        //msg.sender = address
        //payable(msg.sender) = payable address
        // transfer automatically reverts
        //payable(msg.sender).transfer(address(this).balance);
        //send
        // send gives us bool instead of reverting so we have to revert manually
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Sending Failed");
        //call
        // we can call any function virtually in all of ETH without ABI
        // call("") blank means no function called
        //call returns 2 parameters, so we use () to get more than 1.
        //(bool callSuccess, bytes memory dataReturned) = payable(msg.sender).call{value:address(this).balance}("");
        // we can use just ,
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
        // mostly, call is used to send eth currency tokens.
    }

    // we can use libraries to make these 3 below functions and make them custom functions of any type
    //msg.value.getPrice();
    // we can make our own library

    // we will now create below 3 function as library and import them,.
    // function getPrice() public view returns (uint256) {
    //     //Address 0x694AA1769357215DE4FAC081bf1f309aDC325306
    //     // ABI ( get the price from contract, we only need price) we use Interface
    //     // Interface is function declerations that we can use
    //     // interact with the contract that is storing the price of eth
    //     AggregatorV3Interface priceFeed = AggregatorV3Interface(
    //         0x694AA1769357215DE4FAC081bf1f309aDC325306
    //     );
    //     (, int256 price, , , ) = priceFeed.latestRoundData();
    //     // this ignores other values from latestRoundData() and only gives us price.
    //     //price of ETH in USD
    //     // 2000.0000000
    //     // msg.value have 18 decimal and price have 8, so we do this and also cast it into uint256
    //     return uint256(price * 1e10);
    // }

    // function getConversionRate(
    //     uint256 ethAmount
    // ) public view returns (uint256) {
    //     // 1 ETH?
    //     // 2000_0000000000000000
    //     uint256 ethPrice = getPrice();
    //     // (2000_0000000000000000 * 1_00000000000000000) 1e18
    //     // $2000 = 1ETH
    //     uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    //     return ethAmountInUsd;
    // }

    function getVersion() public view returns (uint256) {
        // return
        //     AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
        //         .version();

        return s_priceFeed.version();
    }

    // Modifiers are used to create keywords, which we can use to allow certain users
    // to access certain functions

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not the Owner");

        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;

        //modifer is executed before the function if _ is at the end.
        //modifer is executed after the function if _ is at the top.
    }

    // what happens if someone sends this contract eth without calling the fund function
    // we can use recieve and fallback
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    /**
     *
     * View / Pure functions (getters)
     *
     */

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
