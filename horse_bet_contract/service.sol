// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

/** @title Service Contract for Race 
@author @amankr1279
@notice This contract handles all mathematical operations related to a race.
 */

contract Service {
    uint randNonce = 0;

    /// @notice utility function that generates random number between 1 and HORSES(both inclusive)
    function random(uint HORSES) private returns (uint) {
        randNonce++;
        uint x = uint(keccak256(abi.encodePacked(block.timestamp,msg.sender,randNonce))) % HORSES;
        x = x+1;
        return x;
    }

    function getRaceWinners(uint HORSES) public  returns (uint,uint,uint){
        uint h1 = random(HORSES);
        uint h2 = random(HORSES);
        uint h3 = random(HORSES);
        while (h2 == h1) 
        {
            h2 = random(HORSES);
        }
        while (h3 == h2) 
        {
            h3 = random(HORSES);
        }
        while (h3 == h1) 
        {
            h3 = random(HORSES);
        }

        return( h1, h2, h3);
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