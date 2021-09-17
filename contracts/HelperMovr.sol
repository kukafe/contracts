pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20WithSymbol is IERC20 {
    function symbol() external view returns (string memory);
}


contract HelperMovr is Ownable{

    address[] bases = [
        0x98878B06940aE243284CA214f92Bb71a2b032B8A, // wmovr
        0xB44a9B6905aF7c801311e8F4E76932ee959c663C, // usdt 6 decimals
        0xE3F5a90F9cb311505cd691a46596599aA1A0AD7D, // usdc 6 decimals
        0x6bD193Ee6D2104F14F94E2cA6efefae561A4334B, // solar
        0xB3FB48bF090bEDFF4f6F93FFb40221742E107db7, // moon
        0x218c3c3D49d0E7B37aff0D8bB079de36Ae61A4c0, // mswap
        0x80A16016cC4A2E6a2CACA8a4a498b1699fF0f844, // dai
        
        0x63F2ADf5f76F00d48fe2CBef19000AF13Bb8de82, // free
        0xbD90A6125a84E5C512129D622a75CDDE176aDE5E, // rib

        0x5D9ab5522c64E1F6ef5e3627ECCc093f56167818, // busd
        0x639A647fbe20b6c8ac19E48E2de44ea792c62c5C, // eth
        0x2bF9b864cdc97b08B6D79ad4663e71B8aB65c45c, // bnb
        0x6aB6d61428fde76768D7b45D8BFeec19c6eF91A8 // btc
    ];



    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getLpInfo(IUniswapV2Pair _a, IUniswapV2Factory fac) external view returns (bool isLp, address tok, address quote, address quoteLp, string memory tokStr, string memory quoteStr){

        string memory name = _a.name();
        isLp = compareStrings(name,"SolarBeam LP Token") || compareStrings(name,"Uniswap V2") || compareStrings(name,"SeaDex LP");
        
        if (isLp){
            address tok0 = _a.token0();
            address tok1 = _a.token1();

            for (uint256 i = 0; i < bases.length; i ++){
                address b = bases[i];
                if(tok0 == b || tok1 == b){
                    quote = b;
                    tok = (tok0 == b) ? tok1 : tok0;
                    break;
                }
            }

            tokStr = IERC20WithSymbol(tok).symbol();
            quoteStr = IERC20WithSymbol(quote).symbol();
        } else {
            tok = address(_a);
            quote = address(0);
            // try to find a LP pair to quote price
            for (uint256 i = 0; i < bases.length; i ++){
                address b = bases[i];
                if (fac.getPair(tok, b) != address(0)){
                    quote = b;
                    quoteLp = fac.getPair(tok, b);
                    break;
                }
            }

            tokStr = IERC20WithSymbol(tok).symbol();
            if (quote != address(0)){
                quoteStr = IERC20WithSymbol(quote).symbol();
            }
        }
    }
}