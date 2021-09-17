pragma solidity ^0.6.0;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

interface IERC20WithSymbol is IERC20 {
    function symbol() external view returns (string memory);
}


contract Helper is Ownable{

    address[] bases = [
        0x4446Fc4eb47f2f6586f9fAAb68B3498F86C07521, // wkcs
        0x0039f574eE5cC39bdD162E9A88e3EB1f111bAF48, // usdt
        0x980a5AfEf3D17aD98635F6C5aebCBAedEd3c3430, // usdc
        0xE3F5a90F9cb311505cd691a46596599aA1A0AD7D, // busd
        0xf55aF137A98607F7ED2eFEfA4cd2DfE70E4253b1, // eth
        0x639A647fbe20b6c8ac19E48E2de44ea792c62c5C, // bnb
        0x218c3c3D49d0E7B37aff0D8bB079de36Ae61A4c0, // btc
        0xc9BAA8cfdDe8E328787E29b4B078abf2DaDc2055, // dai
        0x516F50028780B60e2FE08eFa853124438f9E46a7, // kafe
        0x4A81704d8C16d9FB0d7f61B747D0B5a272badf14, // kus
        0xBd451b952dE19F2C7bA2c8c516b0740484E953B2, // kud
        0x755d74d009f656CA1652CBdc135e3b6abfcCc455, // ksf
        0x192F72eFD1009D90B0e6F82Ff27a0a2389F803e5 // kwoof
    ];



    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function getLpInfo(IUniswapV2Pair _a, IUniswapV2Factory fac) external view returns (bool isLp, address tok, address quote, address quoteLp, string memory tokStr, string memory quoteStr){

        string memory name = _a.name();
        isLp = compareStrings(name,"Kudex LP") || compareStrings(name,"Kuswap LPs") || compareStrings(name,"KsfSwap LPs") || compareStrings(name, "ShibanceSwap LPs");
        
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