pragma solidity ^0.6.0;
interface ISwapPathRegistry {
    function getSwapRoute(address _router, address _fromToken, address _toToken) external view returns (address[] memory);
}