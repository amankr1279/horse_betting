// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "token.sol";
import "service.sol";
import "nft.sol";

import "hardhat/console.sol";

/// @title Ownership Manager  
/// @author @amankr1279
/// @notice It defines scopes for each function in contract "Main"
contract OwnershipManager {
    address private _owner;
    constructor() {
        _owner = msg.sender;
    }

    function getOwner() public view returns(address) {
        return _owner;
    }

    function isOwner() internal view returns (bool)  {
        return msg.sender == _owner;
    }

    modifier ownerOnly () {
        require(isOwner(), "Only owner is allowed to execute this function");
        _;
    }
    modifier noOwner() {
        require(!isOwner(),"Owner not allowed to execute this function.");
        _;
    }
}

/// @title Main handler of all betting operations.
/// @author @amankr1279
/// @notice It is a single point of contact for carrying out all betting operations.
contract Main is OwnershipManager {
    address public tokenAddress = 0x28E4AaC535F81b9e79446a0Eb4Bc88c60A699c2d;
    address public nftAddress = 0x2dDC9D257F78C001f45569737278744B89e3206e;
    Horse_Bet token = Horse_Bet(tokenAddress);
    BetReceipt receipt = BetReceipt(nftAddress);
    address public myOwner; 
    uint public raceId;

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
        uint horseNum;
    }

    struct Race {
        string name;
        RACE_TYPE raceType; // should be removed as it is useless
        uint startTime;
        uint raceId;
        uint locationId;
        uint numHorses;
        uint first;
        uint runner;
        uint third;
    }

    mapping (uint => mapping(address => Bet[])) public userBet;
    mapping (uint => mapping (address => bool)) public hasWithdrawn;
    mapping (uint => Race) public raceList; // keeping as map as reset is easier

    // ************************* End storage vars ***************//
    constructor() {
        myOwner = getOwner();
        raceId = 0;
    }
    function acceptEther(uint256 amount, address _token) external payable {
        //logic amount = price X msg.value
    }

    // this method ensures that a logic is implemented only after payment.
    function accept(uint256 amount, address _token) external {
        IERC20 token1 = IERC20(_token);
        require(
            token1.allowance(msg.sender, address(this)) >= amount,
            "you have to approve control of tokens"
        );
        token1.transferFrom(msg.sender, address(this), amount);
        //logic starts
    }

    function startRace(string memory raceName, bool raceType, uint numberofHorses, uint begin) public payable ownerOnly  {
        require(numberofHorses >= 3, "Not enough horses conducting a race");
        require(begin >= block.timestamp, "Date should be in future");

        Race memory currentRace = Race({
            name: raceName,
            raceType: RACE_TYPE.NORTH_AMERICAN,
            startTime: begin,
            raceId: 0,
            locationId: 0,
            numHorses: numberofHorses,
            first: 0,
            runner: 0,
            third: 0
        });
        if (raceType == true) {
            currentRace.raceType = RACE_TYPE.EUROPEAN;
        }
        raceId++;
        raceList[raceId] = currentRace;
    }

    /// @dev Not working. Need to check the reason
    /// @notice Approve spending by this contract
    function approveSpending(uint _amount) public {
        token.approve(address(this), _amount);
    }

    /** @notice This function registers user in a race.
    @param _betAmount, _horse, _betType 
    All tokens are sent to this contract's address as pool for prizemoney.
    // Send the user an NFT when he places the bet as an acknowledgment
    */
    function registerUser(uint _betAmount, uint _horse, uint _betType, uint _raceId) public payable noOwner {
        Race memory currentRace = raceList[_raceId];
        require(block.timestamp >= currentRace.startTime, "Cannot register before race's scheduled start time");
        require((currentRace.first == 0) && (currentRace.runner == 0) && (currentRace.third == 0), "Race is already completed");
        console.log("Before transfer");
        require(
            token.allowance(msg.sender, address(this)) >= _betAmount,
            "you have to approve control of tokens"
        );

        console.log("Require passed");
        token.transferFrom(msg.sender, myOwner, _betAmount);
        console.log("After transfer");
        console.log(msg.sender); // here msg.sender is the current user of "main . sol" contract because he is calling this "main . sol"to add himself

        BET_TYPE x = BET_TYPE.PLACE;
        if (_betType == 1) {
            x = BET_TYPE.STRAIGHT;
        } else if (_betType == 2) {
            x = BET_TYPE.SHOW;
        }
        Bet memory bet = Bet(x, _betAmount, _horse);
        userBet[_raceId][msg.sender].push(bet);
        hasWithdrawn[_raceId][msg.sender] = false;
        receipt.mintTokens();

        console.log("Balance address myOwner: %s", token.balanceOf(myOwner));
        console.log("Balance msg sender: %s", token.balanceOf(msg.sender));
    }

    function raceExecution(uint _raceId) public ownerOnly {
        Race memory currentRace = raceList[_raceId];
        require(block.timestamp >= currentRace.startTime, "Cannot execute before race's scheduled start time");
        require((currentRace.first == 0) && (currentRace.runner == 0) && (currentRace.third == 0), "Race is already completed");
        Service service = new Service();
        (uint h1, uint h2, uint h3) = service.getRaceWinners(currentRace.numHorses);
        currentRace.first = h1;
        currentRace.runner = h2;
        currentRace.third = h3;
        raceList[_raceId] = currentRace;
    }
    /**
    @notice Retuns token to the winners from the owner's account.
    @dev The left amount after sending prize money stays with the contract's owner. 
    */
    function returnToken(uint _raceId) external payable noOwner{
        Race memory currentRace = raceList[_raceId];
        require(block.timestamp >= currentRace.startTime, "Cannot retrieve before race's scheduled start time");
        require((currentRace.first != 0) && (currentRace.runner != 0) && (currentRace.third != 0), "Race is still in execution");
        // if bet's raceId is matched, then only process and after process, set bet amt = 0 to prevent double witdrawal
        require(hasWithdrawn[_raceId][msg.sender] == false, "Alreday withdrawn tokens, cannot do again");
        Bet[] memory bets = userBet[_raceId][msg.sender];
        uint amt = 0;
        uint position = 0;
        for (uint i= 0; i < bets.length; i++) 
        {
            Bet memory bet = bets[i];
            position = findPos(bet.horseNum, _raceId);
            if (bet.betType == BET_TYPE.STRAIGHT && position == 1) {
                amt += bet.amount * 4;
            } 
            if(bet.betType == BET_TYPE.SHOW && position <= 2) {
                amt += bet.amount * 3;
            } 
            if(bet.betType == BET_TYPE.PLACE && position <= 3){
                amt += bet.amount * 2;
            }
        }
        // to prevent double withdrawal
        if(bets.length > 0) {
            hasWithdrawn[_raceId][msg.sender] = true;
        }
        token.transferFrom(myOwner, msg.sender, amt);
        receipt.burnTokens();
        console.log("Sender : ", myOwner); 
        console.log("Receiver this : ", msg.sender); 
        console.log("Balance: %s", token.balanceOf(msg.sender));
    }

    function findPos(uint h, uint _raceId) public view returns (uint){
        Race memory currentRace = raceList[_raceId];
        if (h == currentRace.first) {
            return 1;
        } 
        if (h == currentRace.runner) {
            return 2;
        } 
        if (h == currentRace.third) {
            return 3;
        }
        return 1000;
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