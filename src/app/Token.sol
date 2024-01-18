// For testing purposes.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract GHO is ERC20, Ownable, ERC20Permit {
    constructor(address initialOwner)  // Add the initialOwner argument here
        ERC20("GHO", "GHO")
        ERC20Permit("GHO")
        Ownable(initialOwner)  // Pass initialOwner to the Ownable constructor
    {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}