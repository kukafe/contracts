
pragma solidity ^0.6.0;

import "./IStrategy.sol";
import "./Buybackstrat.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface ISnapshot{
    function registerUser(address user) external;
}
/**
 * @dev Implementation of a vault to deposit funds for yield optimizing.
 * This is the contract that receives funds and that users interface with.
 * The yield optimizing strategy itself is implemented in a separate 'Strategy.sol' contract.
 */
contract GrowthVaultLaunch is ERC20, Ownable, Pausable {
    using SafeERC20 for IERC20;
    using Address for address;                
    using SafeMath for uint256;

    struct StratCandidate {
        address implementation;
        uint proposedTime;
    }

    // The last proposed strategy to switch to.
    StratCandidate public stratCandidate; 
    // The strategy currently in use by the vault.
    address public strategy;
    address public buybackstrat; // DEFUALT NONE FIRST
    ISnapshot public snapshotter;
    
    // The token the vault accepts and looks to maximize.
    IERC20 public token;
    // The minimum time it has to pass before a strat candidate can be approved.
    uint256 public approvalDelay;

    bool public harvestBeforeDeposit = true;
    uint256 public constant FEE_CAP = 30 * 100; // max fee possible 30%

    event NewStratCandidate(address implementation);
    event UpgradeStrat(address implementation);

    event SetHarvestBeforeDeposit(bool b);
    event SetSnapshotter(address a);
    event SetStrategy(address s);
    event ChangeApprovalDelay(uint256 t);
    event SetBuybackStrat(address a);

    mapping (address => uint256) public blockAtZeroCapital;
    mapping (address => uint256) public withdrawn;
    mapping (address => uint256) public deposited;
    event CapitalZeroed(address indexed user);
    event Withdraw(address indexed user, uint256 amtSharesBurned, uint256 amtTokRedemmed);
    event Deposit(address indexed user, uint256 amtSharesMinted, uint256 amtTokSent);
    event PricePerShareUpdated(uint256 pricePerShare);

    /**
     * @dev Sets the value of {token} to the token that the vault will
     * hold as underlying value. It initializes the vault's own '11' token.
     * This token is minted when someone does a deposit. It is burned in order
     * to withdraw the corresponding portion of the underlying assets.
     */
    constructor (string memory name, string memory symbol, address stakingToken) public ERC20(name,symbol) {
        token = IERC20(stakingToken);
        // token = IERC20(0x4A81704d8C16d9FB0d7f61B747D0B5a272badf14);
    }

    function setHarvestBeforeDeposit(bool _b) external onlyOwner{
        harvestBeforeDeposit = _b;
        emit SetHarvestBeforeDeposit(_b);
    }

    function setSnapshotter(address _a) external onlyOwner{
        snapshotter = ISnapshot(_a);
        emit SetSnapshotter(_a);
    }
    bool canDo = true;

    function setStrategy(address _strategy) external onlyOwner{
        require(canDo == true, "can't do");
        require(_strategy != address(0), "no zero address!");
        strategy = _strategy;
        canDo = false;
        emit SetStrategy(_strategy);
    }

    function changeApprovalDelay(uint _time) public onlyOwner{
        require(approvalDelay < 7 days, "too much time");
        require(_time > approvalDelay, "approval delay can only increase");
        approvalDelay = _time;
        emit ChangeApprovalDelay(_time);
    }
    
    function balance() public view returns (uint) {
        return token.balanceOf(address(this)).add(IStrategy(strategy).balanceOf());
    }

    /**
     * @dev Custom logic in here for how much the vault allows to be borrowed.
     * We return 100% of tokens for now. Under certain conditions we might
     * want to keep some of the system funds at hand in the vault, instead
     * of putting them to work.
     */
     
    function available() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    /**
     * @dev Function for various UIs to display the current value of one of our yield tokens.
     * Returns an uint256 with 18 decimals of how much underlying asset one vault share represents.
     */
    function getPricePerFullShare() public view returns (uint256) {
        if (totalSupply()==0){
            return 0;
        }
        return balance().mul(1e18).div(totalSupply());
    }

    /**
     * @dev A helper function to call deposit() with all the sender's funds.
     */
    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }

    /**
     * @dev The entrypoint of funds into the system. People deposit with this function
     * into the vault. The vault is then in charge of sending funds into the strategy.
     */
    function deposit(uint _amount) public {
        if (address(snapshotter) != address(0)){
            snapshotter.registerUser(msg.sender);
        }
        
        if (harvestBeforeDeposit){
            IStrategy(strategy).harvestFromVault(); // distribute rewards first to current stakers
        }
        
        
        
        uint256 _pool = balance();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        earn();
        uint256 _poolAfter = balance();
        _amount = _poolAfter.sub(_pool); // Additional check for deflationary tokens

        uint256 shares = 0;
        if (totalSupply() == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalSupply())).div(_pool);
        }
        _mint(msg.sender, shares);
        emit Deposit(msg.sender, shares, _amount);

    }

    /**
     * @dev Function to send funds into the strategy and put them to work. It's primarily called
     * by the vault's deposit() function.
     */
    function earn() public {
        uint _bal = available();
        token.safeTransfer(strategy, _bal);
        IStrategy(strategy).deposit();
    }

    /**
     * @dev A helper function to call withdraw() with all the sender's funds.
     */
    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }

    /**
     * @dev Function to exit the system. The vault will withdraw the required tokens
     * from the strategy and pay up the token holder. A proportional number of IOU
     * tokens are burned in the process.
     */
    function withdraw(uint256 _shares) public {
        if (harvestBeforeDeposit){
            IStrategy(strategy).harvestFromVault(); // distribute rewards first to current stakers
        }

        uint256 r = (balance().mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares);

        uint b = token.balanceOf(address(this));
        if (b < r) {
            uint _withdraw = r.sub(b);
            IStrategy(strategy).withdraw(_withdraw);
            uint _after = token.balanceOf(address(this));
            uint _diff = _after.sub(b);
            if (_diff < _withdraw) {
                r = b.add(_diff);
            }
        }
        emit Withdraw(msg.sender, _shares, r);

        if (buybackstrat != address(0)){
            uint256 fee = r.mul(getWithdrawFee()).div(10000);
            r = r.sub(fee);
            token.safeTransfer(buybackstrat, fee);
        }
        token.safeTransfer(msg.sender, r);

        uint256 left = balanceOf(msg.sender);
        if (left == 0){
            blockAtZeroCapital[msg.sender] = block.number;
            emit CapitalZeroed(msg.sender);
        }

    }


    function getWithdrawFee() public view returns (uint) {
        uint256 fee = Buybackstrat(buybackstrat).withdrawalFeesBps();
        if (fee > FEE_CAP) {
            fee = FEE_CAP;
        }
        return fee;
    }
    /** 
     * @dev Sets the candidate for the new strat to use with this vault.
     * @param _implementation The address of the candidate strategy.  
     */
    function proposeStrat(address _implementation) public onlyOwner {
        stratCandidate = StratCandidate({ 
            implementation: _implementation,
            proposedTime: block.timestamp
         });

        emit NewStratCandidate(_implementation);
    }

    /** 
     * @dev It switches the active strat for the strat candidate. After upgrading, the 
     * candidate implementation is set to the 0x00 address, and proposedTime to a time 
     * happening in +100 years for safety. 
     */

    function upgradeStrat() public onlyOwner {
        require(stratCandidate.implementation != address(0), "There is no candidate");
        require(stratCandidate.implementation != strategy, "Cannot upgrade to same strategy!");
        require(stratCandidate.proposedTime.add(approvalDelay) < block.timestamp, "Delay has not passed");
        
        emit UpgradeStrat(stratCandidate.implementation);
        address oldStrategy = strategy;

        IStrategy(strategy).retireStrat();
        strategy = stratCandidate.implementation;
        stratCandidate.implementation = address(0);
        stratCandidate.proposedTime = 5000000000;
        
        earn();

        // return ownership to owner
        IStrategy(oldStrategy).transferOwnership(owner());
    }

    function setBuybackStrat(address _address) public onlyOwner{
        buybackstrat = _address;
        IStrategy(strategy).setBuybackStrat(_address);
        emit SetBuybackStrat(_address);
    }
    function setStakingMode(bool _b) external onlyOwner{
        IStrategy(strategy).setStakingMode(_b);
    }
    function setReferralMode(bool _b) external onlyOwner{
        IStrategy(strategy).setReferralMode(_b);
    }
    function setSwapPathRegistry(address _a) external onlyOwner{
        IStrategy(strategy).setSwapPathRegistry(_a);
    }
    function setMinToLiquify(uint256 n) external onlyOwner{
        IStrategy(strategy).setMinToLiquify(n);
    }
    function updatePricePerShare() public {
        emit PricePerShareUpdated(getPricePerFullShare());
    }

}