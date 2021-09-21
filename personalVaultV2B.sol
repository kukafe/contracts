// Sources flattened with hardhat v2.4.3 https://hardhat.org

// File @openzeppelin/contracts/GSN/Context.sol@v3.1.0

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File contracts/ISwapPathRegistry.sol

pragma solidity ^0.6.0;
interface ISwapPathRegistry {
    function getSwapRoute(address _router, address _fromToken, address _toToken) external view returns (address[] memory);
}


// File contracts/IPanwexPair.sol

pragma solidity ^0.6.0;
interface IPanwexPair {
    function token0() external view returns (address);
    function token1() external view returns (address);
}


// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router01.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}


// File @uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol@v1.1.0-beta.0

pragma solidity >=0.6.2;

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}


// File contracts/KCSRouter2.sol

pragma solidity >=0.6.2;
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


// File contracts/Pausable.sol

pragma solidity ^0.6.0;
/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}


// File contracts/Buybackstrat.sol

pragma solidity ^0.6.0;

interface Buybackstrat{
    function performanceFeeBps() external view returns(uint);
    function withdrawalFeesBps() external view returns(uint);
    function setBuybackStrat() external;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


// File @openzeppelin/contracts/math/SafeMath.sol@v3.1.0



pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


// File @openzeppelin/contracts/utils/Address.sol@v3.1.0



pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/SafeERC20.sol@v3.1.0



pragma solidity ^0.6.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


// File contracts/StrategyLPPersonalVault.sol

pragma solidity ^0.6.0;
interface IMasterChefwStakingLockupReferrer {
    
    function deposit(uint256 poolId, uint256 amount) external;
    function withdraw(uint256 poolId, uint256 amount) external;

    function enterStaking(uint256 _amount) external;
    function leaveStaking(uint256 _amount) external;

    function deposit(uint256 poolId, uint256 amount, address referrer) external;
    
    // for lockup type of masterchefs
    function userInfo(uint256 poolId, address user) external view returns (uint256, uint256, uint256, uint256);

    function canHarvest(uint256 _pid, address _user) external view returns (bool);
}
/**
 * @dev Implementation of a strategy to get yields from farming LP Pools in PanwexSwap.
 * PanwexSwap is an automated market maker (“AMM”) that allows two tokens to be exchanged on the Binance Smart Chain.
 * It is fast, cheap, and allows anyone to participate. PanwexSwap is aiming to be the #1 liquidity provider on BSC.
 *
 * This strategy simply deposits whatever funds it receives from the vault into the selected MasterChef pool.
 * CAKE rewards from providing liquidity are farmed every few minutes, sold and split 50/50. 
 * The corresponding pair of assets are bought and more liquidity is added to the MasterChef pool.
 * 
 * This strat is currently compatible with all LP pools.
 */
contract StrategyLPPersonalVault is Ownable, Pausable {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;

    /**
     * @dev Tokens Used:
     * {wkcs} - Required for liquidity routing when doing swaps.
     * {wex} - Token generated by staking our funds. In this case it's the CAKEs token.
     * {eleven} - ElevenFinance token, used to send funds to the treasury.
     * {lpPair} - Token that the strategy maximizes. The same token that users deposit in the vault.
     * {lpToken0, lpToken1} - Tokens that the strategy maximizes. IPanwexPair tokens
     */
    modifier onlyOwnerOrUser() {
        require(owner() == _msgSender() || user == _msgSender() , "Ownable: caller is not the owner/user");
        _;
    }
    modifier onlyUser() {
        require(user == _msgSender() , "Ownable: caller is not the user");
        _;
    }
    
    // modifier onlyVault() {
    //     require(vault == _msgSender() , "Ownable: caller is not the vault");
    //     _;
    // }

    address public lpPair;

    address public rewardToken;
    address public otherToken;
    address public baseToken;

    address public router;
    
    address public masterchef;
    uint256 public poolId;

    
    address public buybackstrat;
    address public swapPathRegistry;
    uint256 public MIN_TO_LIQUIFY = 100; // just not zero.
    bool public stakingMode = false;
    bool public referralMode = false;

    // special stuff for private vault
    address public user;
    bool public exitMode;
    uint256 public amtManualDeposited;
    
    function getFarmIdentifier() external view returns (bytes32){
        return keccak256(abi.encode(lpPair, rewardToken, baseToken, router, masterchef, poolId));
    }   
    function setBuybackStrat(address _address) external onlyOwner{
        buybackstrat = _address;
    }
    function setStakingMode(bool _b) external onlyOwner{
        stakingMode = _b;
    }
    function setReferralMode(bool _b) external onlyOwner{
        referralMode = _b;
    }
    function setSwapPathRegistry(address _a) external onlyOwner{
        swapPathRegistry = _a;
    }
    function setMinToLiquify(uint256 n) external onlyOwner{
        MIN_TO_LIQUIFY = n;
    }
    function depositToFarm(uint256 amt) internal{
        if (stakingMode){
            IMasterChefwStakingLockupReferrer(masterchef).enterStaking(amt);
        } else if (referralMode){
            IMasterChefwStakingLockupReferrer(masterchef).deposit(poolId,amt, address(0));
        } else {
            IMasterChefwStakingLockupReferrer(masterchef).deposit(poolId,amt);
        }
    }
    function withdrawFromFarm(uint256 amt) internal {
        if (stakingMode){
            IMasterChefwStakingLockupReferrer(masterchef).leaveStaking(amt);
        } else {
            IMasterChefwStakingLockupReferrer(masterchef).withdraw(poolId,amt);
        }
    }
    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    /**
     * @dev Initializes the strategy with the token to maximize.
     */
    constructor(address _lpPair, 
    address _rewardToken, 
    address _baseToken, 
    address _masterchef, 
    uint256 _poolId, address _router, address _swapPathRegistry, address _user, address _feeStrat) public {
        lpPair = _lpPair;
        masterchef = _masterchef;
        poolId = _poolId;
        router = _router;
        swapPathRegistry = _swapPathRegistry;
        buybackstrat = _feeStrat;
        
        user = _user;

        if (_baseToken == address(0)){
            // token mode
            otherToken = address(0);
            baseToken = address(0);
        } else {
            address token0 = IPanwexPair(_lpPair).token0();
            address token1 = IPanwexPair(_lpPair).token1();
            (otherToken, baseToken) = (token0 == _baseToken) ? (token1,token0) : (token0,token1);
            IERC20(otherToken).safeApprove(router, 0);
            IERC20(otherToken).safeApprove(router, uint(-1));
            IERC20(baseToken).safeApprove(router, 0);
            IERC20(baseToken).safeApprove(router, uint(-1));
        }

        rewardToken = _rewardToken;

        IERC20(lpPair).safeApprove(masterchef, 0);
        IERC20(lpPair).safeApprove(masterchef, uint(-1));
        IERC20(rewardToken).safeApprove(router, 0);
        IERC20(rewardToken).safeApprove(router, uint(-1));
    }

    function setExitMode(bool _exit) public onlyUser{
        exitMode = _exit;
    }

    function getRewardState() public view returns (uint256 amount, uint256 rewardLockedUp, uint256 nextHarvest) {
        (amount,,rewardLockedUp,nextHarvest) = IMasterChefwStakingLockupReferrer(masterchef).userInfo(poolId, address(this));
    }

    /**
     * @dev Function that puts the funds to work.
     * It gets called whenever someone deposits in the strategy's vault contract.
     * It deposits {lpPair} in the MasterChef to farm {wex}
     */
    function deposit() public{
        require(!exitMode, "In exit mode!");
        // resets the harvest lock!

        uint256 pairBal = IERC20(lpPair).balanceOf(address(this));
        if (pairBal > 0) {
            depositToFarm(pairBal);
             _harvest(false);
            emit Deposit(pairBal);
        }
    }

    function userDeposit(uint256 _amount) external onlyUser{
        IERC20(lpPair).safeTransferFrom(msg.sender, address(this), _amount);
        amtManualDeposited = amtManualDeposited.add(_amount);
        deposit();
    }   
    
    // exit instructions => withdrawal, then wait for at least 1h for remaining reward to be sent to your acc


    /**
     * @dev Withdraws funds and sents them back to the vault.
     * It withdraws {lpPair} from the MasterChef.
     * The available {lpPair} minus fees is returned to the vault.
     */
    function withdraw(uint256 _amount) external onlyUser{
        
        uint256 pairBal = IERC20(lpPair).balanceOf(address(this));

        if (pairBal < _amount) {   
            withdrawFromFarm(_amount.sub(pairBal));
            pairBal = IERC20(lpPair).balanceOf(address(this));
            IERC20(lpPair).safeTransfer(user, pairBal);
            if (pairBal <= amtManualDeposited){
                amtManualDeposited = amtManualDeposited.sub(pairBal);
            } else {
                amtManualDeposited = 0;
            }
            if (!exitMode){
                _harvest(false);
            }

        } else {
            IERC20(lpPair).safeTransfer(user, _amount);
            if (_amount <= amtManualDeposited){
                amtManualDeposited = amtManualDeposited.sub(_amount);
            } else {
                amtManualDeposited = 0;
            }
            if (!exitMode){
                _harvest(true);
            }
        }
        if (exitMode){
            uint256 rewardBal = IERC20(rewardToken).balanceOf(address(this));
            IERC20(rewardToken).safeTransfer(user, rewardBal);
        }
        if (balanceOfPool() == 0){
            amtManualDeposited = 0;
        }
    }
    function exit() external onlyUser{
        _exit();
        exitMode = true;
    }

    function _exit() internal {
        withdrawFromFarm(balanceOfPool());
        uint256 pairBal = IERC20(lpPair).balanceOf(address(this));
        IERC20(lpPair).safeTransfer(user, pairBal);

        uint256 rewardBal = IERC20(rewardToken).balanceOf(address(this));
        IERC20(rewardToken).safeTransfer(user, rewardBal);
        
        if (balanceOfPool() == 0){
            amtManualDeposited = 0;
        }

    }
    
    
    function addliquidity() internal{
        uint amount = IERC20(rewardToken).balanceOf(address(this));
        uint amtToSell = amount.div(2);

        if (baseToken != rewardToken){     
            address[] memory path = ISwapPathRegistry(swapPathRegistry).getSwapRoute(router, rewardToken, baseToken );
            require(path.length > 0, "check swapPathRegistry1");
            KCSRouter2(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amtToSell, 0, path, address(this), now);
        }

        if (otherToken != rewardToken){
            address[] memory path2 = ISwapPathRegistry(swapPathRegistry).getSwapRoute(router, rewardToken, otherToken );
            require(path2.length > 0, "check swapPathRegistry2");
            KCSRouter2(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amtToSell, 0, path2, address(this), now);
        }

        KCSRouter2(router).addLiquidity(otherToken, baseToken, IERC20(otherToken).balanceOf(address(this)), IERC20(baseToken).balanceOf(address(this)), 0, 0, address(this), now);
    }
    function swapToStakingToken() internal{
        if (rewardToken != lpPair){
            uint amount = IERC20(rewardToken).balanceOf(address(this));
            address[] memory path = ISwapPathRegistry(swapPathRegistry).getSwapRoute(router, rewardToken, lpPair);
            require(path.length > 0, "check swapPathRegistry3");
            KCSRouter2(router).swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(this), now);
        }
    }

    /**
     * @dev Core function of the strat, in charge of collecting and re-investing rewards.
     * 1. It claims rewards from the MasterChef.
     * 2. It charges the system fees to simplify the split.
     * 3. It swaps the {wex} token for {lpToken0} & {lpToken1}
     * 4. Adds more liquidity to the pool.
     * 5. It deposits the new LP tokens.
     */
    function harvest() external {
        require(!Address.isContract(msg.sender), "!contract");
        _harvest(true);
    }
    function exitHarvest() external {
        require(!Address.isContract(msg.sender), "!contract");
        require(exitMode, "not exitmode!");
        
        _exit();
    }
    function canExitHarvest() external view returns (bool) {
        // to check if bot should call exitHarvest function
        uint256 rewardBal = IERC20(rewardToken).balanceOf(address(this));
        (, uint256 rewardLockedUp,) = getRewardState();
        return 
            (IMasterChefwStakingLockupReferrer(masterchef).canHarvest(poolId, address(this)) && rewardLockedUp > 0) ||
            (balanceOfPool() > 0) || 
            (rewardBal > 0);

    }
    function _harvest(bool claimPendingRewards) internal whenNotPaused {

        if (exitMode){
            return;
        }
        if (claimPendingRewards && IMasterChefwStakingLockupReferrer(masterchef).canHarvest(poolId, address(this))){
            depositToFarm(0);
        }
        uint256 rewardTokenBal = IERC20(rewardToken).balanceOf(address(this));
        if (rewardTokenBal == 0 || rewardTokenBal < MIN_TO_LIQUIFY){
            return;
        }
        chargeFees();
        if (baseToken != address(0)){
            addliquidity();
        } else {
            swapToStakingToken();
        }
        uint256 bal = balanceOfLpPair();
        if (bal > 0){
            depositToFarm(bal);
        }
    }

    function getBPSFee() public view returns (uint) {
        return Buybackstrat(buybackstrat).performanceFeeBps();
    }

    function chargeFees() internal {
        if(buybackstrat!=address(0)){
            uint toSell = IERC20(rewardToken).balanceOf(address(this)).mul(getBPSFee()).div(10000);
            IERC20(rewardToken).transfer(buybackstrat, toSell);
        }
    }
    
    /**
     * @dev Function to calculate the total underlaying {lpPair} held by the strat.
     * It takes into account both the funds in hand, as the funds allocated in the MasterChef.
     */
    function balanceOf() public view returns (uint256) {
        return balanceOfLpPair().add(balanceOfPool());
    }

    /**
     * @dev It calculates how much {lpPair} the contract holds.
     */
    function balanceOfLpPair() public view returns (uint256) {
        return IERC20(lpPair).balanceOf(address(this));
    }

    /**
     * @dev It calculates how much {lpPair} the strategy has allocated in the MasterChef
     */
    function balanceOfPool() public view returns (uint256) {
        (uint256 _amount,,,) = IMasterChefwStakingLockupReferrer(masterchef).userInfo(poolId, address(this));
        return _amount;
    }

    /**
     * @dev Pauses deposits. Withdraws all funds from the MasterChef, leaving rewards behind
     */
    function panic() public onlyOwnerOrUser {
        pause();
        withdrawFromFarm(balanceOfPool());
        if (balanceOfPool() == 0){
            amtManualDeposited = 0;
        }
    }

    function saveToken(address _token) external {
        require(msg.sender == user, "only user!");
        IERC20 token = IERC20(_token);
        uint256 tokenBalance = token.balanceOf(address(this));
        token.transfer(msg.sender, tokenBalance);
    }

    /**
     * @dev Pauses the strat.
     */
    function pause() public onlyOwnerOrUser {
        _pause();
        IERC20(lpPair).safeApprove(masterchef, 0);
        IERC20(rewardToken).safeApprove(router, 0);
        if (baseToken != address(0)){
            IERC20(otherToken).safeApprove(router, 0);
            IERC20(baseToken).safeApprove(router, 0);
        }
    }

    /**
     * @dev Unpauses the strat.
     */
    function unpause() external onlyOwnerOrUser {
        _unpause();

        IERC20(lpPair).safeApprove(masterchef, 0);
        IERC20(lpPair).safeApprove(masterchef, uint(-1));
        IERC20(rewardToken).safeApprove(router, 0);
        IERC20(rewardToken).safeApprove(router, uint(-1));
        if (baseToken != address(0)){
            IERC20(otherToken).safeApprove(router, 0);
            IERC20(otherToken).safeApprove(router, uint(-1));
            IERC20(baseToken).safeApprove(router, 0);
            IERC20(baseToken).safeApprove(router, uint(-1));
        }
    }
}
