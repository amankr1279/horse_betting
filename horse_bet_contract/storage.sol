// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// store:-
/** user's total bet amount
total number of users in a race
total number of bet amount --> winner
*/
import "hardhat/console.sol";

// contract Receiver {
//     event ValueReceived(address user, uint amount);

//     receive() external payable {
//         emit ValueReceived(msg.sender, msg.value);
//     }
// }

contract Storage {
    mapping(address => uint) public userBet;
    mapping(uint => address) public horseBettor;
    address[] public totalUsers; // map
    uint public totalAmount;
    uint public immutable HORSES;

    function registerUser(address _user, uint _betAmount, uint _horse) public {
        // receive betAmount from each user
        userBet[_user] = _betAmount;
        totalAmount += _betAmount;
        totalUsers.push(_user);
        horseBettor[_horse] = _user;
    }

    constructor() {
        totalAmount = 0;
        HORSES = 5;
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

    function pickWinner() public view returns (address, uint) {
        uint winnerHorse = random();
        address winnerUser = horseBettor[winnerHorse];
        // send tokens to this user's address
        return (winnerUser, totalAmount);
    }
}
