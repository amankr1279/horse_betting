# About

This is a decentralized horse-race betting platform built on Ethereum blockchain. It has following features:-

- Horse race's contract owners can register a race where they can specify the number of horses, the time of commencement and its name.
- The owners can also execute a race after its commencement time.
- Bettors can place bets on horses and collect rewards post the race's completion. 
- The bettors can place bets in only the native tokens of the smart contract. 
- The bettors can place 3 types of bets:- *STRAIGHT, PLACE and SHOW*.
   - **STRAIGHT** : On horses who will come first in a race
   - **SHOW**: On horses who will come first or second in a race.
   - **PLACE**: On horses who will finish in top 3 positions in a race.
- After placing a bet, the bettor receives and NFT as an acknowledgment.   

### How to run this contract on local machine? 

Follow these steps:-

1. Download the git repo
2. Create a Remix ethereum account or if it is there then open it.
3. Go to ```cd horse_bet_contract```.
4. In this folder, run ```remixd -s ./ -u https://remix.ethereum.org``` and in remix ide choose workspace as localhost.
5. You should be able to see all the contracts in Remix IDE now.

### Where is it deployed?

The contract is deployed on a *Sepolia Testnet*. It can be found here:-
- [Tokens](https://sepolia.etherscan.io/address/0x28E4AaC535F81b9e79446a0Eb4Bc88c60A699c2d)
- [NFT](https://sepolia.etherscan.io/address/0x2dDC9D257F78C001f45569737278744B89e3206e)
- [Main](https://sepolia.etherscan.io/address/0xF0485973084f0bb0D10A9A0fC8DdC5C20B1Be60c)

Owner:- `0x9A9785ab60fCaeABe25F252d4f83Cdc9c208ce67`

### How to improve?

* Fork the repo from `dev` branch and make your changes.
* Raise a PR for `dev` branch named as `feature/feature_name`

----------

Author: @amankr1279