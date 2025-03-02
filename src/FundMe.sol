//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PriceConverter.sol";

error FundMe__InsufficientAmountSent();
error FundMe__ContractHasNoBalance();
error FundMe__OnlyOwnerCanWithdrawFunds();
error FundMe__WithdrawalFailed();
error FundMe__AddressHasNotFunded();

contract FundMe {
    PriceConverter priceConverter;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public immutable i_owner;
    address[] public funders;
    mapping(address => uint256) s_amountFunded;
    bool private locked = false;

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

    function withdraw() public onlyOwner noReentrancy {
        uint256 contractBalance = address(this).balance;
        if (contractBalance == 0) {
            revert FundMe__ContractHasNoBalance();
        }
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            s_amountFunded[funder] = 0;
        }
        // funders = new address[](0);
        delete funders;
        (bool success, ) = payable(msg.sender).call{value: contractBalance}("");
        if (!success) {
            revert FundMe__WithdrawalFailed();
        }

        emit Withdrawn(msg.sender, contractBalance);
    }

    function getFundedAmount(address user) public view returns (uint256) {
        return s_amountFunded[user];
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getFunder(uint256 index) public view returns (address) {
        if (index >= funders.length) {
            revert FundMe__AddressHasNotFunded();
        }
        return funders[index];
    }

    function getFunders() public view returns (address[] memory) {
        return funders;
    }

    function getVersion() public view returns (uint256) {
        return priceConverter.getVersion();
    }

    receive() external payable {
        fund();
    }

    // fallback() external payable { // this would be triggered  when a tx is sent woth params
    //     fund();
    // }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert FundMe__OnlyOwnerCanWithdrawFunds();
        }
        _;
    }

    //Before the function body is executed, the modifier checks require(!locked, "No reentrancy allowed");. This condition ensures that the function won't be executed if locked is true.
    // When the function starts executing, the modifier sets locked = true, which prevents any further re-entry into the function. The function can’t be called recursively, ensuring that no reentrancy attacks can occur.
    modifier noReentrancy() {
        require(!locked, "No reentrancy allowed");
        locked = true;
        _;
        locked = false;
    }
}
