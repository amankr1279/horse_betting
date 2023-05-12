// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./.deps/npm/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./.deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "./.deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "./.deps/npm/@openzeppelin/contracts/access/Ownable.sol";
import "./.deps/npm/@openzeppelin/contracts/security/Pausable.sol";
import "./.deps/npm/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "./.deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "./.deps/npm/@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";

contract Horse_Bet is
    ERC20,
    ERC20Burnable,
    ERC20Snapshot,
    Ownable,
    Pausable,
    ERC20Permit,
    ERC20Votes,
    ERC20FlashMint
{
    constructor() ERC20("Horse_Bet", "BET") ERC20Permit("Horse_Bet") {}

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Snapshot) whenNotPaused {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._mint(to, amount);
    }

    function _burn(
        address account,
        uint256 amount
    ) internal override(ERC20, ERC20Votes) {
        super._burn(account, amount);
    }
}
