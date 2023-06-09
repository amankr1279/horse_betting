// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// store:-
/* user's total bet amount
total number of users in a race
total number of bet amount --> winner
*/
/** @title Storage Contract for Race 
@author Aman Kumar
@notice This contract stores and handles all operations related to a race.
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

    struct Bet {
        BET_TYPE betType;
        uint amount;
    }

    struct Race {
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
    uint public immutable HORSES; // mutable in future
    uint public immutable BETCAP;

    // Race[] public raceList;
    Race public currentRace;

    // prize Money for each user
    mapping(address => uint) public Loot;

    /** @notice This function registers user in a race.
    @param _user, _betAmount, _horse, _typeOfBet
     */
    function registerUser(
        address _user,
        uint _betAmount,
        uint _horse,
        uint _typeOfBet
    ) public {
        // receive betAmount from each user
        console.log("Inside registerUser");
        BET_TYPE x = BET_TYPE.PLACE;
        if (_typeOfBet == 1) {
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

    /** @notice This function prints all users in a race on console.
     */
    function listAllUsers() public view {
        for (uint i = 0; i < totalUsers.length; i++) {
            console.log(totalUsers[i]); // "and bet =  ", userBet[totalUsers[i]]);
        }
    }

    constructor() {
        totalAmount = 0;
        HORSES = 5;
        BETCAP = 500;
    }

    /// @notice utility function that generates random number between 0 and 4(both inclusive)
    function random(uint randNonce) public view returns (uint) {
        uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % HORSES;
    }

    /// @notice Calculates left amount for betting in a race.
    /// @dev This check needs to be integrated in main.sol contract.
    function leftAmountForBets(uint _betAmount) public view returns (bool) {
        return (BETCAP - (totalAmount + _betAmount)) >= 0;
    }

    function getRaceWinners() public pure returns (uint,uint,uint){
        uint h1 = 1;
        uint h2 = 2;
        // while (h1 == h2) 
        // {
        //     h2 = random();
        // }
        uint h3 = 3;
        // while (h3 == h1 || h3 == h2) 
        // {
        //     h3 = random();
        // }
        return( h1, h2, h3);
    }

    /// @dev utility function that gets winner list and adjust prize money according to
    /// the prize factor
    function getWinnerList(
        uint _prizeFactor
    ) public view returns (address[] memory, uint) {
        uint winnerHorse = random(1); // not checking if same horse is returned for more than 1 position
        uint prize = 0;
        address[] memory winnerUsers = horseBettor[winnerHorse];
        while (winnerUsers.length == 0) {
            winnerHorse = random(2);
            winnerUsers = horseBettor[winnerHorse];
        }
        prize = totalAmount / (winnerUsers.length * _prizeFactor);

        return (winnerUsers, prize);
    }

    /// @notice Picks 1st, 2nd and 3rd horse of a race and creates a list of prizemoney and winners who
    /// will get that.
    function pickWinner()
        public
        view
        returns (
            address[] memory,
            address[] memory,
            address[] memory,
            uint[] memory
        )
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
        @notice Prize Strategy:- 
        straight winner => totalAmount/ (1 * winnerLength);
        place winner => totalAmount/ (2 * winnerLength);
        show winner => totalAmount/ (4 * winnerLength);
        */

        return (
            winnerStraightUsers,
            winnerPlaceUsers,
            winnerShowUsers,
            prizeMoney
        );
    }

    function allocationUtil(uint horse, uint position) public {
        address[] memory winners = horseBettor[horse];
        for (uint i=0 ; i < winners.length; i++) 
        {
            Bet memory bet = userBet[winners[i]];
            console.log("bet : ", bet.amount);
            // console.log("" , bet.betType);
            if (bet.betType == BET_TYPE.STRAIGHT && position == 1) {
                Loot[winners[i]] += bet.amount * 6;
            } 
            if(bet.betType == BET_TYPE.SHOW && position <= 2) {
                Loot[winners[i]] += bet.amount * 4;
            } 
            if(bet.betType == BET_TYPE.PLACE && position <= 3){
                Loot[winners[i]] += bet.amount * 2;
            }
        }
    }

    function raceExec() public   {
        (uint h1,uint h2,uint h3) = getRaceWinners();
        // address[] memory w1; 
        // address[] memory w2;
        // address[] memory w3;
        // w1 = horseBettor[h1];
        // w2 = horseBettor[h2];
        // w3 = horseBettor[h3];

        // 2 lists: user and corresponding prize money
        // OR, store it in a map and query it as per user's addr input --> seems better
        allocationUtil(h1,1);
        allocationUtil(h2,2);
        allocationUtil(h3,3);
    }

    /// @notice resets all state variables of the race
    /// @dev Integration with main.sol contract needs re-work.
    function reset(string memory raceName, bool isEuropean) external {
        for (uint i = 0; i < totalUsers.length; i++) {
            delete userBet[totalUsers[i]];
        }
        for (uint i = 0; i < HORSES; i++) {
            delete horseBettor[i];
        }

        totalUsers = new address[](0);
        totalAmount = 0;
        // delete raceList;
        currentRace = Race(raceName, RACE_TYPE.NORTH_AMERICAN, block.timestamp + 10 minutes);
        if (isEuropean == true) {
            currentRace.raceType = RACE_TYPE.EUROPEAN;
        }
    }
}

/*
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

// Loops are costly, try maps.
// transaction fn should not have loops, put them in view type