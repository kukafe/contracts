pragma solidity ^0.6.0;

import "./KCSRouter2.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

interface IVault is IERC20{
    function getPricePerFullShare() external view returns(uint256);
    function token() external view returns(address);
}

// at every snapshot, i query this contract for in/out of vault.
contract Snapshot is Ownable{ 
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;
    IERC20 wkcs = IERC20(0x98878B06940aE243284CA214f92Bb71a2b032B8A);

    mapping(address=>bool) vaultWhitelist;

    EnumerableSet.AddressSet users;

    modifier onlyVault() {
        require(vaultWhitelist[_msgSender()] || owner() == _msgSender() , "Ownable: caller is not the wl vault");
        _;
    }
    function setVaultWhitelist(address _v, bool _b) external {
        vaultWhitelist[_v] = _b;
    }

    function getUserStakeValue(address user, IVault vault, address baseToken) external view returns (uint256){
        uint256 numUnderlyingStake = vault.balanceOf(user).mul(vault.getPricePerFullShare()).div(1e18);

        // assume underlying stakes are LPs
        IUniswapV2Pair pair = IUniswapV2Pair(vault.token());
        uint256 amtBaseInLp = IERC20(baseToken).balanceOf(vault.token()).mul(2);
        return amtBaseInLp.mul(numUnderlyingStake).div(pair.totalSupply());

    }
    function getUserStakeTokenValue(address user, IVault vault, address[] memory path, KCSRouter2 router) external view returns (uint256){
        uint256 numUnderlyingStake = vault.balanceOf(user).mul(vault.getPricePerFullShare()).div(1e18);
        if (numUnderlyingStake > 0){
            uint256[] memory amts = router.getAmountsOut(numUnderlyingStake, path);
            return amts[amts.length - 1];
        }
        return 0;
    }
    function registerUser(address user) external onlyVault {
        users.add(user);
    }

    function getNumUsers() external view returns (uint256){
        return users.length();
    }
    function getUserByI(uint256 i) external view returns(address){
        return users.at(i);
    }
}