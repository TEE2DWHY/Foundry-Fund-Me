//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

contract PriceConverter {
    AggregatorV3Interface internal dataFeed;

    constructor(address _priceFeedAddress) {
        dataFeed = AggregatorV3Interface(_priceFeedAddress);
    }

    function getPrice() public view returns (uint256) {
        (
            ,
            /* uint80 roundID */
            int256 answer /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = dataFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    function getConversionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 amountInUsd = (ethAmount * ethPrice) / 1e18;
        return amountInUsd;
    }

    function getVersion() public view returns (uint256) {
        return dataFeed.version();
    }
}
