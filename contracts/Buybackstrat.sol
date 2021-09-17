pragma solidity ^0.6.0;

interface Buybackstrat{
    function performanceFeeBps() external view returns(uint);
    function withdrawalFeesBps() external view returns(uint);
    function setBuybackStrat() external;
}