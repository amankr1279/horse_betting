// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./token.sol";
import "./service.sol";

// import "hardhat/console.sol";

/// @title Main handler of all betting operations.
/// @author @amankr1279
/// @notice It is a single point of contact for carrying out all betting operations.

contract Main is Ownable {
    address public tokenAddress = 0x86c3259c19f69D64634d0D7297B52CF299cab74d;

    //**************** Storage vars ***********************//
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
        uint raceId;
        uint locationId;
        uint first;
        uint second;
        uint third;
    }

    mapping(address => Bet) public userBet;
    mapping(uint => address[]) public horseBettor; 
    address[] public totalUsers;
    uint public totalAmount;
    uint public immutable HORSES; // mutable in future
    // uint public immutable BETCAP;

    // Race[] public raceList;
    Race public currentRace;

    // prize Money for each user
    mapping(address => uint) public Loot;

    // ************************* End storage vars ***************//

    function getHorseBettors(uint horse) view external returns (address[]){
        return horseBettor[horse];
    }

    function getLoot(address userAddress) view external returns (address){
        return Loot[userAddress];
    }

    function acceptEther(uint256 amount, address _token) external payable {
        //logic amount = price X msg.value
    }

    // this method ensures that a logic is implemented only after payment.
    function accept(uint256 amount, address _token) external {
        IERC20 token = IERC20(_token);
        require(
            token.allowance(msg.sender, address(this)) >= amount,
            "you have to approve control of tokens"
        );
        token.transferFrom(msg.sender, address(this), amount);
        //logic starts
    }

    function startRace(string memory raceName, bool raceType, uint numberofHorses, uint begin) public payable {
        // // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        // IERC20 token = Horse_Bet(tokenAddress);
        // // simpleStorage.reset(raceName, raceType);
        // console.log("Balance address this: %s", token.balanceOf(address(this)));
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
        if (raceType == true) {
            currentRace.raceType = RACE_TYPE.EUROPEAN;
        }
    }


    /// @dev Not working. Need to check the reason
    /// @notice Approve spending by this contract
    function approveSpending(uint _amount) public {
        Horse_Bet token = Horse_Bet(tokenAddress);
        token.approve(address(this), _amount);
    }

    /** @notice This function registers user in a race.
    @param _betAmount, _horse, _betType 
    All tokens are sent to this contract's address as pool for prizemoney.
    // TODO : Send the user an NFT when he places the bet
    */
    function registerUser(uint _betAmount, uint _horse, uint _betType) public payable {
        // approve the transfer
        Horse_Bet token = Horse_Bet(tokenAddress);
        console.log("Before transfer");
        require(
            token.allowance(msg.sender, address(this)) >= _betAmount,
            "you have to approve control of tokens"
        );

        console.log("Require passed");
        token.transferFrom(msg.sender, address(this), _betAmount);
        console.log("After transfer");
        console.log(msg.sender); // here msg.sender is the current user of "main . sol" contract because he is calling this "main . sol"to add user

        BET_TYPE x = BET_TYPE.PLACE;
        if (_betType == 1) {
            x = BET_TYPE.STRAIGHT;
        } else if (_betType == 2) {
            x = BET_TYPE.SHOW;
        }
        Bet memory bet = Bet(x, _betAmount);
        userBet[msg.sender] = bet;
        totalAmount += _betAmount;
        totalUsers.push(msg.sender);
        horseBettor[_horse].push(msg.sender);

        console.log("Balance address this: %s", token.balanceOf(address(this)));
        console.log("Balance msg sender: %s", token.balanceOf(msg.sender));
    }

    function raceExecution() public {
        // (uint h1, uint h2, uint h3) = Service.getRaceWinners();

    }
    /**
    @notice Retuns token to the winners from the creator's account.
    @dev The left amount after sending prize money should be sent to this contract's owner. 
    */
    function returnToken() external onlyOwner payable{

        // (
        //     address[] memory winnerStraightUsers,
        //     address[] memory winnerPlaceUsers,
        //     address[] memory winnerShowUsers,
        //     uint[] memory amount
        // ) = Service.pickWinner();
        (uint h1, uint h2, uint h3) = Service.getRaceWinners();

        Horse_Bet token = Horse_Bet(tokenAddress);
        console.log("Straight Winner prize", amount[0]);
        console.log("Place Winner prize", amount[1]);
        console.log("Show Winner prize", amount[2]);

        for (uint i = 0; i < winnerStraightUsers.length; i++) {
            token.transfer(winnerStraightUsers[i], amount[0]);
        }

        for (uint i = 0; i < winnerPlaceUsers.length; i++) {
            token.transfer(winnerPlaceUsers[i], amount[1]);
        }
        for (uint i = 0; i < winnerShowUsers.length; i++) {
            token.transfer(winnerShowUsers[i], amount[2]);
        }

        console.log("Sender : ", msg.sender); // --> owner of token contract
        console.log("Address this : ", address(this)); // -> main.sol's address
        console.log("Balance: %s", token.balanceOf(address(this)));
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
}
/** Flow of the application.
1. The creator approves spending of tokens for all users who want to partake in betting
2. The creator of the contract transfers some tokens to all users.
3. Each User approves the "main . sol" contract to spend tokens on his/her behalf.
4. Each user then registers his bet against a horse. This is done by transferring all the hedged tokens 
   to the creator's address.
5. The winner is picked randomly and all the hedged tokens are transferred to him from the creator's account
 */

// Token contract:- 0xd9145CCE52D386f254917e481eB44e9943F39138
// Storage contract:- 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// 18 zeroes:- 000000000000000000

// update the transferFrom works only is the sender is "msg.sender" but we need to deduct from the added user's account. --> Resolved

// TODO: Transfrom this from a single race to multiple races
