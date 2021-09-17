pragma solidity ^0.6.0;


interface WrappedRouter {
    function getAmountsOut(uint amountIn, address[] memory path, uint fee) external view returns (uint256[] memory amounts);
}

contract RouterWrapper{
    WrappedRouter router;

    constructor(address _router) public {
        router = WrappedRouter(_router);
    }
  function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint256[] memory amounts){
    return router.getAmountsOut(amountIn, path, 0);
    // uint256[] memory results = new uint256[](path.length);

    // for (uint256 i = 0; i < path.length-1; i++){
    //   results[i] = amountIn;
    // }
    // results[path.length - 1] = router.getAmountsOut(amountIn, path, 0);

    // return results;
  }

}