// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./storage.sol";
import "hardhat/console.sol";

contract Main {
    Storage public simpleStorage =
        Storage(0x38cB7800C3Fddb8dda074C1c650A155154924C73);

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

    function registerUser(address _user, uint _betAmount, uint _horse) public {
        // approve the transfer
        address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        IERC20 token = IERC20(tokenAddress);
        console.log("Before transfer");
        require(
            token.allowance(msg.sender, address(this)) >= _betAmount,
            "you have to approve control of tokens"
        );
        token.transferFrom(msg.sender, address(this), _betAmount);
        console.log("After transfer");
        simpleStorage.registerUser(_user, _betAmount, _horse);
    }

    function returnToken() external view {
        uint amount;
        address winner;
        (winner, amount) = simpleStorage.pickWinner();
        address tokenAddress = 0xd9145CCE52D386f254917e481eB44e9943F39138;
        IERC20 token = IERC20(tokenAddress);
        console.log(winner, amount);
        //    token.transfer(winner, amount);
        console.log("Balance: %s", token.balanceOf(address(this)));
    }
}
/** Flow of the application.
1. The creator approces spending of tokens for all users who want to partake in betting
2. The creator of the contract transfers some tokens to all users.
3. Each user then registers his bet against a horse. This is done by transferring all the hedged tokens 
   to the creator's address.
4. The winner is picked randomly and all the hedged tokens are trasnferred to him from the creator
 */
