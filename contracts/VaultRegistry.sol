pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";

interface IPrivateVault{
    function getFarmIdentifier() external view returns (bytes32);
    function user() external view returns (address);
}
contract VaultRegistry is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet users;
    EnumerableSet.AddressSet vaults;

    mapping(address => address[]) public userVaults;
    mapping(bytes32 => address[]) public vaultsByIdent;


    mapping(address => string) public vaultTypes;

    mapping(address => bool) public wlVaults;
    event VaultDeployed(address indexed user, address vault);


    // vault => bool
    mapping(address => bool) public deactivated;

    modifier onlyWlVaultFactory() {
        require(wlVaults[_msgSender()] || owner() == _msgSender() , "Ownable: caller is not wl vault");
        _;
    }
    constructor() public {
    }
    function setWhitelistVaultFactory(address fac, bool b) external onlyOwner{
        wlVaults[fac] = b;
    }

    function getNumTotalVaults() external view returns (uint256){
        return vaults.length();
    }
    function getVaultAt(uint256 i) external view returns (address){
        return vaults.at(i);
    }
    function getNumUsers() external view returns (uint256) {
        return users.length();
    }
    function getUserAt(uint256 i) external view returns (address){
        return users.at(i);
    }
    function getUserVaults(address _user) external view returns (address[] memory) {
        return userVaults[_user];
    }
    function getVaultsByIdent(bytes32 ident) external view returns (address[] memory) {
        return vaultsByIdent[ident];
    }

    function registerVault(address _user, address _vault, string calldata vaultType) external onlyWlVaultFactory{
        userVaults[_user].push(_vault);

        if (!users.contains(_user)){
            users.add(_user);
        }
        if (!vaults.contains(_vault)){
            vaults.add(_vault);
        }
        vaultTypes[_vault] = vaultType;
        vaultsByIdent[IPrivateVault(_vault).getFarmIdentifier()].push(_vault);
    }

    function deregisterVault(address _vault, bool b) external {
        address user = IPrivateVault(_vault).user();
        require(msg.sender == user || msg.sender == owner(), "not authorized to deactivate");
        deactivated[_vault] = b;
    }

}