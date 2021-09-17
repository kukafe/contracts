pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract FeeStrategy is Ownable{

    // 10000

    // vault
    uint256 public withdrawalFeesBps = 0.1*100;
    uint256 public performanceFeeBps = 3.5*100;

    // // farm
    // uint256 public depositTax = 4*100;

    address DEAD = 0x000000000000000000000000000000000000dEaD;

    function setWithdrawalFee(uint256 n) external onlyOwner {
        require (n < 20 * 100, "Max is 20%");
        withdrawalFeesBps = n;
    }
    function setPerformanceFee(uint256 n) external onlyOwner{
        require (n < 20 * 100, "Max is 20%");
        performanceFeeBps = n;
    }
    // function setDepositTax(uint256 n) external onlyOwner{
    //     depositTax = n;
    // }

    function drainEth() external onlyOwner {
        uint256 b = address(this).balance;
        payable(owner()).send(b);    
    }

    function drainToken(IERC20 _token) external onlyOwner {
        IERC20 token = IERC20(_token);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(owner(), tokenBalance);
    }


    function liquifyToken(IERC20 _token, IUniswapV2Router02 router, address[] memory path) external onlyOwner {
        _token.approve(address(router), uint(-1));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(_token.balanceOf(address(this)), 0, path, address(this), now);
    }
    function liquifyLP(IUniswapV2Pair _token, IUniswapV2Router02 router) external onlyOwner {
        _token.approve(address(router), uint(-1));
        router.removeLiquidity(_token.token0(), _token.token1(), _token.balanceOf(address(this)), 0,0, address(this),now);
    }

    function buyNBurnToken(uint256 amt, IUniswapV2Router02 router, address[] memory path) external onlyOwner {
        IERC20(path[0]).approve(address(router), uint256(-1));
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amt, 0, path, DEAD, now);
    }

    function burnToken(uint256 amt, address token) external onlyOwner {
        IERC20(token).transfer(DEAD, amt);
    }

    receive() external payable {}

}