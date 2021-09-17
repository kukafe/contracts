pragma solidity ^0.6.0;

interface IStrategy {
    function want() external view returns (address);
    function deposit() external;
    function withdraw(uint256) external;
    function balanceOf() external view returns (uint256);
    function harvest() external;
    function harvestFromVault() external;
    function retireStrat() external;
    
    function setBuybackStrat(address _address) external;
    function setStakingMode(bool _b) external;
    function setReferralMode(bool _b) external;
    function setSwapPathRegistry(address _a) external;
    function setMinToLiquify(uint256 n) external;

    function transferOwnership(address _a) external;
}
