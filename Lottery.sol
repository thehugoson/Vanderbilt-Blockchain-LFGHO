// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint256 public totalStaked;
    address public winner;
    uint256 public startTime;
    uint256 constant public oneMinute = 1 minutes;

    mapping(address => uint256) public userStakes;
    address[] public participants;

    event Staked(address indexed user, uint256 amount);
    event LotteryDrawn(address indexed winner, uint256 prize);

    constructor() {
        owner = msg.sender;
        startTime = block.timestamp;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyDuringStakingPeriod() {
        require(block.timestamp < startTime + oneMinute, "Staking period has ended");
        _;
    }

    function stake() external onlyDuringStakingPeriod payable {
        uint256 amount = msg.value;
        require(amount > 0, "Amount of Ether must be greater than 0");

        if (userStakes[msg.sender] == 0) {
            participants.push(msg.sender);
        }

        userStakes[msg.sender] += amount;
        totalStaked += amount;

        emit Staked(msg.sender, amount);
    }

    function drawLottery() external onlyOwner payable {
        require(totalStaked > 0, "No funds in the lottery pool");
        require(block.timestamp >= startTime + oneMinute, "Staking period has not ended yet");

        uint256 highestStake = 0;

        for (uint256 i = 0; i < participants.length; i++) {
            address user = participants[i];
            if (userStakes[user] > highestStake) {
                highestStake = userStakes[user];
                winner = user;
            }
        }

        uint256 prize = totalStaked;
        payable(winner).transfer(prize);

        totalStaked = 0;
        delete winner;
        delete participants;

        emit LotteryDrawn(winner, prize);
    }
}
