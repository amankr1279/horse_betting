// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// store:-
/** user's total bet amount
total number of users in a race
total number of bet amount --> winner
*/
import "hardhat/console.sol";

contract Storage {
    enum RACE_TYPE {
        NORTH_AMERICAN,
        EUROPEAN
    }

    enum BET_TYPE {
        STRAIGHT, 
        SHOW,
        PLACE 
    }

    struct Bet{
        BET_TYPE betType;
        uint amount;
    }

    struct Race{
        string name;
        RACE_TYPE raceType;
        uint startTime;
        // uint raceId;
        // uint locationId;
    }

    mapping(address => Bet) public userBet;
    mapping(uint => address[]) public horseBettor; // to be changed to list
    address[] public totalUsers; 
    uint public totalAmount;
    uint public immutable HORSES;
    uint public immutable BETCAP;
    
    // Race[] public raceList;
    Race public currentRace;

    function registerUser(address _user, uint _betAmount, uint _horse, uint _typeOfBet) public {
        // receive betAmount from each user
        console.log("Inside registerUser");
        BET_TYPE x = BET_TYPE.PLACE;
        if(_typeOfBet == 1){
            x = BET_TYPE.STRAIGHT;
        } else if (_typeOfBet == 2) {
            x = BET_TYPE.SHOW;
        }
        Bet memory bet = Bet(x, _betAmount);
        userBet[_user] = bet;
        totalAmount += _betAmount;
        totalUsers.push(_user);
        horseBettor[_horse].push(_user);
        console.log("Done registerUser");
        
    }

    function listAllUsers() public view {
        for(uint i = 0; i < totalUsers.length; i++) {
            console.log(totalUsers[i] ); // "and bet =  ", userBet[totalUsers[i]]);
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

    function getWinnerList(uint _prizeFactor) public view returns(address[] memory, uint){
        uint winnerHorse = random();
        uint prize = 0;
        address[] memory winnerUsers = horseBettor[winnerHorse];
        while (winnerUsers.length == 0) {
            winnerHorse = random();
            winnerUsers = horseBettor[winnerHorse];
            
        }
        prize = totalAmount/(winnerUsers.length * _prizeFactor);
        
        return (winnerUsers, prize);
    }


    function pickWinner() public view returns (
        address[] memory,
        address[] memory,
        address[] memory, 
        uint[] memory) 
        {
        // winner should be picked acc to race type
        
        (address[] memory winnerStraightUsers, uint stPrize) = getWinnerList(1);
        (address[] memory winnerPlaceUsers, uint showPrize) = getWinnerList(2);
        (address[] memory winnerShowUsers, uint placePrize) = getWinnerList(4);
        // send tokens to this user's address
        uint[] memory prizeMoney = new uint[](3);
        prizeMoney[0] = stPrize;
        prizeMoney[1] = placePrize;
        prizeMoney[2] = showPrize;
        /**
        straight winner => totalAmount/ (1 * winnerLength);
        place winner => totalAmount/ (2 * winnerLength);
        show winner => totalAmount/ (4 * winnerLength);
        */
        
        return (winnerStraightUsers, winnerPlaceUsers, winnerShowUsers, prizeMoney);
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
6. Winner picking needs some modification.
7. Number of horses should be alterable.
8. Multiple races should be hosted at once.
9. Time check is still pending.
*/