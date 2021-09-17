pragma solidity ^0.6.0;
interface IPanwexPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}
