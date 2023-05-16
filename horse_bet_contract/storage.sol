// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// store:-
/** user's total bet amount
total number of users in a race
total number of bet amount --> winner
*/
import "hardhat/console.sol";

contract Storage {
    mapping(address => uint) public userBet;
    mapping(uint => address) public horseBettor; // to be changed to list
    address[] public totalUsers; // map
    uint public totalAmount;
    uint public immutable HORSES;
    uint public immutable BETCAP;
    enum RACE_TYPE {
        NORTH_AMERICAN,
        EUROPEAN
    }

    enum BET_TYPE {
        STRAIGHT, 
        SHOW,
        PLACE 
    }

    struct Race{
        string name;
        RACE_TYPE raceType;
        uint startTime;
    }
    // Race[] public raceList;
    Race public currentRace;

    function registerUser(address _user, uint _betAmount, uint _horse) public {
        // receive betAmount from each user
        console.log("Inside registerUser");
        userBet[_user] = _betAmount;
        totalAmount += _betAmount;
        totalUsers.push(_user);
        horseBettor[_horse] = _user;
        console.log("Done registerUser");
        
    }

    function listAllUsers() public view {
        for(uint i = 0; i < totalUsers.length; i++) {
            console.log(totalUsers[i], " and bet =  ", userBet[totalUsers[i]]);
        }
    }

    constructor() {
        totalAmount = 0;
        HORSES = 5;
        BETCAP = 500;
    }

    function random() public view returns (uint) {
        return
            uint(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % HORSES;
    }

    function leftAmountForBets(uint _betAmount) public view returns (bool){
        return (BETCAP - (totalAmount + _betAmount)) >= 0;
    }

    function pickWinner() public view returns (address, uint) {
        // winner should be picked acc to race type
        uint winnerHorse = random();
        address winnerUser = horseBettor[winnerHorse];
        while (winnerUser == address(0)) {
            winnerHorse = random();
            winnerUser = horseBettor[winnerHorse];
        }
        // send tokens to this user's address
        return (winnerUser, totalAmount);
    }

    function reset(string memory raceName,bool isEuropean) external {
        for (uint i = 0; i < totalUsers.length; i++) {
            delete userBet[totalUsers[i]];
        }
        for (uint i = 0; i < HORSES; i++) {
            delete horseBettor[i];
        }
        
        totalUsers = new address[](0);
        totalAmount = 0;
        // delete raceList;
        currentRace = Race(raceName, RACE_TYPE.NORTH_AMERICAN, block.timestamp);
        if(isEuropean == true){
            currentRace.raceType = RACE_TYPE.EUROPEAN;
        }
    }
}

/**
Need functions like:-
1. reset race. Done
2. duplicate entries should not be there. 
3. limit max tokens that can be hedged in a race. --> 500 Done but check not working in main.sol
4. Main.sol must have 10,000 tokens to begin with and it will transfer the prize money to winner Done
5. if pick winner returns "0x00" then rerun the pickWinner Done
*/