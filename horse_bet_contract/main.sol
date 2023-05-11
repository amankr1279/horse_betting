// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "horse_betting/storage.sol";
import "hardhat/console.sol";

contract Main {
    Storage public simpleStorage = new Storage();

    function acceptEther(uint256 amount, address _token) payable external {
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
       this.accept(_betAmount, _user);
       simpleStorage.registerUser(_user, _betAmount, _horse);
   }


   function returnToken() external {
       uint amount;
       address winner;
       (winner, amount) = simpleStorage.pickWinner();
       IERC20 token = IERC20(winner);
       token.transfer(msg.sender, amount);
   }
}