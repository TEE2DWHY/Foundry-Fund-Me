//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PriceConverter.sol";

error FundMe__InsufficientAmountSent();
error FundMe__ContractHasNoBalance();
error FundMe__OnlyOwnerCanWithdrawFunds();
error FundMe__WithdrawalFailed();

contract FundMe {
    PriceConverter priceConverter;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public immutable i_owner;
    address[] public funders;
    mapping(address => uint256) s_amountFunded;

    event Funded(address indexed funder, uint256 amount);
    event Withdrawn(address indexed owner, uint256 amount);

    constructor(address _dataFeedAddress) {
        priceConverter = new PriceConverter(_dataFeedAddress);
        i_owner = msg.sender;
    }

    function fund() public payable {
        uint256 amountInUsd = priceConverter.getConversionRate(msg.value);
        if (amountInUsd < MINIMUM_USD) {
            revert FundMe__InsufficientAmountSent();
        }
        funders.push(msg.sender);
        s_amountFunded[msg.sender] += (msg.value);

        emit Funded(msg.sender, msg.value);
    }

    function getConverstionRate(
        uint256 ethAmount
    ) public view returns (uint256) {
        return priceConverter.getConversionRate(ethAmount);
    }

    function withdraw() public payable onlyOwner {
        uint256 contractBalance = address(this).balance;
        if (contractBalance == 0) {
            revert FundMe__ContractHasNoBalance();
        }
        (bool success, ) = payable(msg.sender).call{value: contractBalance}("");
        if (!success) {
            revert FundMe__WithdrawalFailed();
        }

        emit Withdrawn(msg.sender, contractBalance);
    }

    function getFundedAmount(address user) public view returns (uint256) {
        return s_amountFunded[user];
    }

    function getVersion() public view returns (uint256) {
        return priceConverter.getVersion();
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "Only owner can withdraw funds");
        _;
    }
}
