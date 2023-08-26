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
        if (HORSES <= 7) {
            h1 = 1;
            h2 = 2;
            h3 = 3;
        } 
        else {
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
        }

        return( h1, h2, h3);
    }
    
}
