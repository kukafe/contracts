// File: contracts/KudexToken.sol
pragma solidity >=0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Test is ERC20, Ownable{
    constructor() public ERC20("test", "test"){
        _mint(msg.sender, 1 ether);
    }
}