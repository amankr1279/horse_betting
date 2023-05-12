// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./token.sol";
import "./storage.sol";
import "hardhat/console.sol";

contract Main {
    Storage public simpleStorage =
        Storage(0xd16B472C1b3AB8bc40C1321D7b33dB857e823f01);
    address public tokenAddress = 0x838F9b8228a5C95a7c431bcDAb58E289f5D2A4DC;
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

    function startRace() public  {
        // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        IERC20 token = IERC20(tokenAddress);
        simpleStorage.reset();
        console.log("Balance address this: %s", token.balanceOf(address(this)));
    }

    function registerUser(address _user, uint _betAmount, uint _horse) public {
        // approve the transfer
        // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        Horse_Bet token = Horse_Bet(tokenAddress);
        console.log("Before transfer");
        require(
            token.allowance(msg.sender, address(this)) >= _betAmount,
            "you have to approve control of tokens"
        );
        // require(
        //     simpleStorage.leftAmountForBets(_betAmount), 
        //     "hedged amount exceeds the total cap of 500"
        // ); 
        
        console.log("Require passed");
        token.transferFrom(msg.sender, address(this), _betAmount);
        console.log("After transfer");
        console.log(msg.sender); // here msg.sender is the owner of Token contract because he is calling this main.sol to add user
        simpleStorage.registerUser(_user, _betAmount, _horse);
        console.log("Balance address this: %s", token.balanceOf(address(this)));
        console.log("Balance msg sender: %s", token.balanceOf(msg.sender));
        console.log("Balance user: %s", token.balanceOf(_user));
    }

    function returnToken() external   {
        uint amount;
        address winner;
        (winner, amount) = simpleStorage.pickWinner();
        // address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        IERC20 token = IERC20(tokenAddress);
        console.log(winner, amount);
        
        console.log("Sender : ",msg.sender); // --> owner of token contract
        console.log("Address this : ",address(this)); // -> main.sol's address
        console.log("Balance: %s", token.balanceOf(address(this)));

        token.transfer(winner, amount);
    }
} 
/** Flow of the application.
1. The creator approves spending of tokens for all users who want to partake in betting
2. The creator of the contract transfers some tokens to all users.
3. Each user then registers his bet against a horse. This is done by transferring all the hedged tokens 
   to the creator's address.
4. The winner is picked randomly and all the hedged tokens are trasnferred to him from the creator's account
 */

// Token contract:- 0xd9145CCE52D386f254917e481eB44e9943F39138
// Storage contract:- 0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8
// 18 zeroes:- 000000000000000000

// update the transferFrom works only is the sender is "msg.sender" but we need to deduct from the added user's account.
