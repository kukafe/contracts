pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./StrategyLPPersonalVault.sol";

interface IVaultRegistry {
    function registerVault(address user, address vault, string calldata vaultType) external;
}
contract PrivateVaultFactory_LPReferralHarvestLock is Ownable {

    // VaultTemplate[] public vaultTemplates;
    address public vaultRegistry;
    string public constant VAULT_TYPE="StrategyLPPersonalVault2b";

    event SetVaultRegistry(address _a);
    event VaultCreated(address user, address vault, address lpPair, string vaultType);

    constructor() public {
    }

    function setVaultRegistry(address _r) external onlyOwner {
        vaultRegistry = _r;
        emit SetVaultRegistry(_r);
    }

    function createVault(address _lpPair, 
        address _rewardToken, 
        address _baseToken, 
        address _masterchef, 
        uint256 _poolId, address _router, address _swapPathRegistry, 
        address _user, address _feeStrat, bool _stakingMode, bool _referralMode) external returns (address) {
        require(msg.sender == _user, "only can create own vault");

        StrategyLPPersonalVault temp = new StrategyLPPersonalVault(_lpPair,
            _rewardToken,
            _baseToken,
            _masterchef,
            _poolId,
            _router,
            _swapPathRegistry,
            _user,
            _feeStrat
        );
        temp.setStakingMode(_stakingMode);
        temp.setReferralMode(_referralMode);

        temp.transferOwnership(owner());
        IVaultRegistry(vaultRegistry).registerVault(_user, address(temp), VAULT_TYPE);
        emit VaultCreated(_user, address(temp), _lpPair, VAULT_TYPE);
        
        return address(temp);
    }
}