pragma solidity >=0.6.2;
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface KCSRouter2 is IUniswapV2Router02{
 
     function addLiquidityKCS(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
//     function addLiquidity(
//         address tokenA,
//         address tokenB,
//         uint amountADesired,
//         uint amountBDesired,
//         uint amountAMin,
//         uint amountBMin,
//         address to,
//         uint deadline
//     ) external returns (uint amountA, uint amountB, uint liquidity);
//   function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
  
        
//     function swapExactTokensForTokensSupportingFeeOnTransferTokens(
//         uint amountIn,
//         uint amountOutMin,
//         address[] calldata path,
//         address to,
//         uint deadline
//     ) external;
  
  
}