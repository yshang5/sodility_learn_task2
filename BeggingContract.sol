// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract BeggingContract {

    uint public epoch;
    address public owner;
    uint public totalDonation;

    mapping(uint => mapping(address => uint)) private donationByEpoch;

    address[] private donators;

    event EthReceived(address indexed from, uint amount, uint epoch);
    event Withdraw(address indexed to, uint amount, uint epoch);
    event NewEpoch(uint epoch);

    constructor() {
        owner = msg.sender;
        epoch = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function donate() external payable {
        require(msg.value > 0, "no ETH sent");

        if (donationByEpoch[epoch][msg.sender] == 0) {
            donators.push(msg.sender);
        }

        donationByEpoch[epoch][msg.sender] += msg.value;
        totalDonation += msg.value;

        emit EthReceived(msg.sender, msg.value, epoch);
    }

    function getDonation(address donator)
        external
        view
        returns (uint)
    {
        return donationByEpoch[epoch][donator];
    }


    function withdraw() external onlyOwner {
        uint amount = address(this).balance;
        require(amount > 0, "no balance");
        (bool success, ) = owner.call{value: amount}("");
        if (success) {
            emit Withdraw(owner, amount, epoch);    
        } 
    }

    // ===== 重置（进入新一轮）=====
    function nextEpoch() external onlyOwner {
        epoch += 1;
        delete donators;
        emit NewEpoch(epoch);
    }
}
