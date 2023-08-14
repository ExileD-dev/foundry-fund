// SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    // setup always runs first
    //AccessListuint256 public number;
    FundMe fundMe;
    // fake user (prank) to send all tx
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //number = 2;
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // after updating deployfundme
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // giving fake money to fake user
        vm.deal(USER, STARTING_BALANCE);
    }

    // function testDemo() public {
    //     //console.log(number);
    //     //assertEq(number, 2);
    //     //forge test -vv (v is visibility of console logs, can do -vvvvv)
    // }

    function testMinimumUsd() public {
        console.log(fundMe.MINIMUM_USD());
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        //   Fail Test =  assertEq(fundMe.MINIMUM_USD(), 6e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));

        // assertEq(fundMe.i_owner(), msg.sender);
        // above is fail test because, us -> fundMeTest -> fundMe
        // so we called test function to deploy contract
        // so we are not the owner but fundMeTest is.
        //assertEq(fundMe.i_owner(), address(this));
        // after updating and refactoring, so that our test is deploying
        // from deployFundMe script, now the owner is again DeployFundMe
        // and not FundMeTest so we can go back and test like this.
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        console.log(version);
        assertEq(version, 4);
        // this is failing again, because its getting the version
        // of contract that does not exist bcz anvil is off right now
        // and test is deploying on its own contract.

        // to solve this
        // multiple tests, Unit, intergration, forked, staging.
        // unit => testing a specfic part of code
        // integration => testing how code works with other part of code
        // forked => testing code on simulated real environment
        // staging => testing code in real environ that is not production

        // this is fork testing
        // get sepolia rpc from alchemy and put it in .env, also put .env in gitignore
        // forge test -vvvvv --fork-url $SEPOLIA_RPC
        // anvil will now pretend to run deploy and read from sepolia chain
        // instead of blank chain like before.
        // now the above test will be successfull
        // downside is fork testing takes alot of resources on alchemy
        // forge coverage -vvvvv --fork-url $SEPOLIA_RPC
        //                       --rpc-url (same thing)
        // coverage will tell us how many lines of our code as tested
    }

    // modular testing and modular deployements
    // where we dnt have our addresses hardcoded with sepolia
    // so we can deploy and test to other chains easier
    // did above in helper config

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // next line should revert!
        fundMe.fund();
        // above is less than minimum eth, (its 0)
        //forge test --match-test testFundFailsWithoutEnoughEth
        // if i run this now, it will pass bcz the line after expect revert
        // will fail
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // next tx will be send by fake user
        fundMe.fund{value: SEND_VALUE}();
        // address(this) vs msg.sender
        // we dnt know which one is the owner,
        // so we use prank from foundry to make fake address
        // so we dnt have to choose btw address(this) or msg.sender
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        // added funded modifier at the top to reduce code
        // vm.prank(USER);
        // fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        //txGasPrice (to depict real life gas senario)
        //  uint256 gasStart = gasleft(); //1000
        //  vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //c :200
        fundMe.withdraw();
        //  uint256 gasEnd = gasleft(); //800
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);
        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        // if we want to use numbers to generate addresses
        // we should use uint160
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        // i =1, bcz sometimes 0 address reverts
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //vm.prank
            //vm.deal
            // fund the fundMe

            // hoax prank and give money to address so it does prank and deal
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Asert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }

    // foundry feature = Chisel
    // chisel (in terminal)
    // it allows us to write solidity in terminal

    //forge snapshot --match-test testWithdrawFromMultipleFunders
    // makes a snapshot file to give us gas info for a specific test

    // for all above test, bcz they r test, its not using gas for tx
    // we can use txGasPrice() function to depict real life gas tx

    // using storage variable test
    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
