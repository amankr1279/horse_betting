// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./token.sol";
import "./storage.sol";
import "hardhat/console.sol";

contract Main is Ownable{
    Storage public simpleStorage =
        Storage(0xb27A31f1b0AF2946B7F582768f03239b1eC07c2c);
    address public tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
    // IERC20 token = IERC20(tokenAddress);    

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

    function startRace(string memory raceName, bool raceType ) public  {
        // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        IERC20 token = IERC20(tokenAddress);
        simpleStorage.reset(raceName, raceType );
        
        console.log("Balance address this: %s", token.balanceOf(address(this)));

    }

    function approveSpending(uint _amount) public {
        Horse_Bet token = Horse_Bet(tokenAddress);
        token.approve(address(this), _amount);
    }

    function registerUser(uint _betAmount, uint _horse, uint _betType) public {
        // approve the transfer
        // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        Horse_Bet token = Horse_Bet(tokenAddress);
        console.log("Before transfer");
        require(
            token.allowance(msg.sender, address(this)) >= _betAmount,
            "you have to approve control of tokens"
        );
        
        console.log("Require passed");
        token.transferFrom(msg.sender, address(this), _betAmount);
        console.log("After transfer");
        console.log(msg.sender); // here msg.sender is the current user of Main.sol contract because he is calling this main.sol to add user
        
        simpleStorage.registerUser(msg.sender, _betAmount, _horse, _betType);
        console.log("Balance address this: %s", token.balanceOf(address(this)));
        console.log("Balance msg sender: %s", token.balanceOf(msg.sender));
    }

    function returnToken() external  onlyOwner {
        (address[] memory winnerStraightUsers,
        address[] memory winnerPlaceUsers,
        address[] memory winnerShowUsers, 
        uint[] memory amount) = simpleStorage.pickWinner();
        IERC20 token = IERC20(tokenAddress);
        console.log("Straight Winner prize",amount[0]);
        console.log("Place Winner prize",amount[0]);
        console.log("Show Winner prize",amount[0]);
        
        for (uint i=0; i < winnerStraightUsers.length ; i++) 
        {
            token.transfer(winnerStraightUsers[i], amount[0]);
        }

        for (uint i=0; i < winnerPlaceUsers.length ; i++) 
        {
            token.transfer(winnerPlaceUsers[i], amount[1]);
        }
        for (uint i=0; i < winnerShowUsers.length ; i++) 
        {
            token.transfer(winnerShowUsers[i], amount[2]);
        }
         
        console.log("Sender : ",msg.sender); // --> owner of token contract
        console.log("Address this : ",address(this)); // -> main.sol's address
        console.log("Balance: %s", token.balanceOf(address(this)));
    }
} 
/** Flow of the application.
1. The creator approves spending of tokens for all users who want to partake in betting
2. The creator of the contract transfers some tokens to all users.
3. Each User approves the main.sol contract to spend tokens on his/her behalf.
4. Each user then registers his bet against a horse. This is done by transferring all the hedged tokens 
   to the creator's address.
5. The winner is picked randomly and all the hedged tokens are transferred to him from the creator's account
 */

// Token contract:- 0xd9145CCE52D386f254917e481eB44e9943F39138
// Storage contract:- 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// 18 zeroes:- 000000000000000000

// update the transferFrom works only is the sender is "msg.sender" but we need to deduct from the added user's account. --> Resolved

// TODO: Transfrom this from a single race to multiple races
