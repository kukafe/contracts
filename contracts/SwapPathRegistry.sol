pragma solidity >=0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SwapPathRegistry is Ownable {
    // router -> from -> to
    mapping(address => mapping(address => mapping(address => address[]))) public routes;

    function addRoute(
        address _router,
        address _from,
        address _to,
        address[] calldata path
    ) external onlyOwner {
        require(_from != address(0), "Src token is invalid");
        require(_to != address(0), "Dst token is invalid");
        require(_from != _to, "Src token must be diff from Dst token");
        require(_router != address(0), "Router is invalid");
        require(path[0] == _from, "Route must start with src token");
        require(path[path.length - 1] == _to, "Route must end with dst token");
        routes[_router][_from][_to] = path;
    }

    function getSwapRoute(address _router, address _fromToken, address _toToken)
        external
        view
        returns (address[] memory _path)
    {
        _path = routes[_router][_fromToken][_toToken];
    }
}