// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PowerballLottery {
    address public owner;
    IERC20 public ghoToken; // GHO token contract
    uint256 public totalStaked;
    uint256 public currentWeek;
    uint256 public drawTime;
    uint256 constant public oneWeek = 1 weeks;

    mapping(address => uint256) public userStakes;
    mapping(address => LotteryTicket) public tickets;
    mapping(address => bool) public hasStakedThisRound;
    address[] public winners;

    struct LotteryTicket {
        uint8[5] numbers;
        uint8 specialNumber;
        bool claimed;
    }

    event Staked(address indexed user, uint256 amount);
    event LotteryDrawn(address indexed winner, uint256 prize, uint8[5] numbers, uint8 specialNumber);
    event NumbersDrawn(uint8[5] numbers, uint8 specialNumber);
    event MyNumbers(address indexed user, uint8[5] numbers, uint8 specialNumber);
    event WinningsClaimed(address indexed winner, uint256 prize);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier onlyDuringStakingPeriod() {
        require(block.timestamp < drawTime, "Staking period for the current week has ended");
        _;
    }

    constructor(address _ghoToken) {
        owner = msg.sender;
        ghoToken = IERC20(_ghoToken);
        drawTime = block.timestamp + oneWeek;
    }

    function stake() external onlyDuringStakingPeriod {
        require(!hasStakedThisRound[msg.sender], "You can only stake once");

        if (userStakes[msg.sender] == 0) {
            winners.push(address(0)); // Initialize the winner placeholder
        }

        uint8[5] memory chosenNumbers;
        uint8 chosenSpecialNumber;

        do {
            (chosenNumbers, chosenSpecialNumber) = generateRandomNumbers(block.timestamp);
        } while (numbersAlreadyTaken(chosenNumbers, chosenSpecialNumber));

        uint256 amount = 2; // 2 GHO tokens 
        userStakes[msg.sender] += amount;
        totalStaked += amount;
        hasStakedThisRound[msg.sender] = true;

        require(ghoToken.transferFrom(msg.sender, address(this), amount), "GHO token transfer failed");

        tickets[msg.sender] = LotteryTicket(chosenNumbers, chosenSpecialNumber, false);

        emit Staked(msg.sender, amount);
        emit MyNumbers(msg.sender, chosenNumbers, chosenSpecialNumber);
    }

    function numbersAlreadyTaken(uint8[5] memory chosenNumbers, uint8 chosenSpecialNumber) internal view returns (bool) {
        for (uint256 i = 0; i < winners.length; i++) {
            LotteryTicket memory existingTicket = tickets[winners[i]];

            if (checkTicket(chosenNumbers, chosenSpecialNumber, existingTicket)) {
                return true; // Numbers already taken, generate new ones
            }
        }

        return false; // Numbers are unique
    }

    function getStakedUsers() internal view returns (address[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < winners.length; i++) {
            if (userStakes[winners[i]] > 0) {
                count++;
            }
        }

        address[] memory stakedUsers = new address[](count);
        count = 0;
        for (uint256 i = 0; i < winners.length; i++) {
            if (userStakes[winners[i]] > 0) {
                stakedUsers[count] = winners[i];
                count++;
            }
        }

        return stakedUsers;
    }

    function drawLottery() external onlyOwner {
        require(block.timestamp >= drawTime, "Drawing time for the current week has not arrived yet");

        uint8[5] memory drawnNumbers;
        uint8 drawnSpecialNumber;
        (drawnNumbers, drawnSpecialNumber) = generateRandomNumbers(block.timestamp);

        emit NumbersDrawn(drawnNumbers, drawnSpecialNumber);

        // Check for winners
        for (uint256 i = 0; i < winners.length; i++) {
            address winner = winners[i];
            LotteryTicket memory ticket = tickets[winner];

            if (checkTicket(drawnNumbers, drawnSpecialNumber, ticket)) {
                uint256 prize = calculatePrize();
                emit LotteryDrawn(winner, prize, drawnNumbers, drawnSpecialNumber);
            }
        }

        // Reset for the next week
        currentWeek++;
        drawTime = block.timestamp + oneWeek;

        // Reset users that have staked
        address[] memory stakedUsers = getStakedUsers();
        for (uint256 i = 0; i < stakedUsers.length; i++) {
            delete tickets[stakedUsers[i]];
            hasStakedThisRound[stakedUsers[i]] = false;
        }
    }


    function claimWinnings() external {
        require(winners.length > 0, "No winners in the current round");

        bool isWinner = false;
        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                isWinner = true;
                break;
            }
        }

        require(isWinner, "You are not a winner or have already claimed winnings");

        uint256 prize = calculatePrize();
        require(prize > 0, "No winnings available");

        payable(msg.sender).transfer(prize);
        emit WinningsClaimed(msg.sender, prize);

        // Remove the winner from the list
        for (uint256 i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                delete winners[i];
                break;
            }
        }

        // Reset total staked amount
        totalStaked = 0;
    }

    function getMyNumbers() external view returns (uint8[5] memory, uint8) {
        require(userStakes[msg.sender] > 0, "No staking found for the user");
        LotteryTicket memory ticket = tickets[msg.sender];
        return (ticket.numbers, ticket.specialNumber);
    }

    function checkTicket(uint8[5] memory drawnNumbers, uint8 drawnSpecialNumber, LotteryTicket memory ticket) internal pure returns (bool) {
        bool numbersMatch = true;
        for (uint8 i = 0; i < 5; i++) {
            if (ticket.numbers[i] != drawnNumbers[i]) {
                numbersMatch = false;
                break;
            }
        }
        return numbersMatch && (ticket.specialNumber == drawnSpecialNumber);
    }

    // Currently, we are sending the entire pot to all users. Need to account for cases with partial winnings
    // (if that's something we want to include) or if multiple users have same numbers that win.
    function calculatePrize() internal view returns (uint256) {
        return totalStaked;
    }

    function generateRandomNumbers(uint256 seed) internal view returns (uint8[5] memory, uint8) {
        uint8[5] memory drawnNumbers;
        uint8 drawnSpecialNumber;

        bytes32 blockHash = blockhash(block.number - 1);
        seed ^= uint256(blockHash);

        for (uint8 i = 0; i < 5; i++) {
            drawnNumbers[i] = uint8(uint256(keccak256(abi.encodePacked(seed, i))) % 69 + 1);
        }

        drawnSpecialNumber = uint8(uint256(keccak256(abi.encodePacked(seed, uint8(5)))) % 26 + 1);

        return (drawnNumbers, drawnSpecialNumber);
    }

    // The following functions are for dev purposes only. Would not include in actual implementation
    function endLotteryManually() external onlyOwner {
        drawTime = block.timestamp;  
    } 

    function makeWinner(address user) external onlyOwner {
        require(userStakes[user] > 0, "User has no stakes");

        winners.push(user);
    }
}