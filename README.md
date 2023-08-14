## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
<!-- 
Tests are important, its good practice, if our contract is without test its not a good 
contract.

// setup always runs first
 // fake user (prank) to send all tx
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

    // modular testing and modular deployements
    // where we dnt have our addresses hardcoded with sepolia
    // so we can deploy and test to other chains easier
    // did above in helper config

    // we dnt know which one is the owner,
    // so we use prank from foundry to make fake address
    // so we dnt have to choose btw address(this) or msg.sender
    // hoax prank and give money to address so it does prank and deal

    // foundry feature = Chisel
    // chisel (in terminal)
    // it allows us to write solidity in terminal

    //forge snapshot --match-test testWithdrawFromMultipleFunders
    // makes a snapshot file to give us gas info for a specific test

    // for all above test, bcz they r test, its not using gas for tx
    // we can use txGasPrice() function to depict real life gas tx

    
// Instead of pasting the whole interface of each contract we want to interact with,
// we can use github to directly import this interface.
 // using constant and immutable allows us to make our code more gas effecient.
    //constant can be changed
    //immutable can only be updated once in the constructor
    //payable makes function accept native BC currency, makes button red.
    / require is like if else, we can ask for someting like (1 eth)
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

        // to make funcution more cheaper and gas effecient, we can use
    // storage variables

    
    // we can use libraries to make these 3 below functions and make them custom functions of any type
    //msg.value.getPrice();
    // we can make our own library

     // Modifiers are used to create keywords, which we can use to allow certain users
    // to access certain functions
        //modifer is executed before the function if _ is at the end.
        //modifer is executed after the function if _ is at the top.


    // what happens if someone sends this contract eth without calling the fund function
    // we can use recieve and fallback

    // to fund our most recently deployed cotnract
// we can use forge install Cyfrin/foundry-devops --no-commit
// and then import devopstools like below


//1. Deploy mocks where we are on local anvil chain
keep track of contract address across different chain
Sepolia ETH/USD
Mainnet ETH/USD

// is Scipt gives vm variable

    if we are on a local anvil, we deploy mocks
    otherwise, grab the existing address from live network

    price feed address
    anvil is different bcz we need to use mocks bcz contracts dnt exists
    as compared to live networks

    if we dont do the above if, it will create a new price feed
    but if we have already deployed one we can use it again
    but checking is the address is not 0
    means we have deployed it before and we get the active network

        1. Deploy mock (fake/dummy contract)
        2. return mock address

        
     if we change anything from script, we also have to change in test
     so we can update above and import deployFundMe in test first and then

      // Mock
    Instead of calling alchemy for every single test and waste resources
    we can use mock to deploy fake local price feed

    now to use helper config and to make deploying more dynamic for different chain

    // Make Files
    Makefiles allows us to create shortcuts for command we are going to use commanly.

    
 -->