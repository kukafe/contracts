// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract MasterChefNoMint is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;         // How many LP tokens the user has provided.
        uint256 rewardDebt;     // Reward debt. See explanation below.
    }

    // Info of each pool.
    struct PoolInfo {
        IERC20 lpToken;           // Address of LP token contract.
        uint256 allocPoint;       // How many allocation points assigned to this pool. EGGs to distribute per block.
        uint256 lastRewardBlock;  // Last block number that EGGs distribution occurs.
        uint256 accKafePerShare;   // Accumulated EGGs per share, times 1e12. See below.
        uint16 depositFeeBP;      // Deposit fee in basis points
    }

    // The EGG TOKEN!
    IERC20 public kafe;
    // Dev address.
    address public devaddr;
    // EGG tokens created per block.
    uint256 public kafePerBlock;
    // Bonus muliplier for early kafe makers.
    uint256 public constant BONUS_MULTIPLIER = 1;
    // Deposit Fee address
    address public feeAddress;
    address public depositedKafe;

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    // Total allocation points. Must be the sum of all allocation points in all pools.
    uint256 public totalAllocPoint = 0;
    // The block number when EGG mining starts.
    uint256 public startBlock;
    uint256 public endBlock;

    mapping(address => mapping(uint256 => uint256)) public feeFactor;
    // address -> pool -> rate
    // if 0, means normal deposit fee.
    // if non 0, multiply the fee by this factor.

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event SetFeeAddress(address indexed user, address indexed newAddress);
    event SetDevAddress(address indexed user, address indexed newAddress);
    event UpdateEmissionRate(address indexed user, uint256 goosePerBlock);

    constructor(
        IERC20 _kafe,
        address _devaddr,
        address _feeAddress,
        uint256 _kafePerBlock,
        uint256 _startBlock
    ) public {
        kafe = _kafe;
        devaddr = _devaddr;
        feeAddress = _feeAddress;
        kafePerBlock = _kafePerBlock;
        startBlock = _startBlock;
        endBlock = _startBlock + ((999999999 days)/3);
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function setEndBlock(uint256 b) external onlyOwner{
        endBlock = b;
    }

    mapping(IERC20 => bool) public poolExistence;
    modifier nonDuplicated(IERC20 _lpToken) {
        require(poolExistence[_lpToken] == false, "nonDuplicated: duplicated");
        _;
    }
    function setFactor(address _a, uint256 _poolId, uint256 _bps) external onlyOwner(){
        feeFactor[_a][_poolId] = _bps;
    }
    

    // Add a new lp to the pool. Can only be called by the owner.
    function add(uint256 _allocPoint, IERC20 _lpToken, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner nonDuplicated(_lpToken) {
        // require(_depositFeeBP <= 10000, "add: invalid deposit fee basis points");
        require(_depositFeeBP <= 5000, "max 50% fee");
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolExistence[_lpToken] = true;
        poolInfo.push(PoolInfo({
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accKafePerShare : 0,
            depositFeeBP : _depositFeeBP
        }));
         // 100 = 1%
    }

    // Update the given pool's EGG allocation point and deposit fee. Can only be called by the owner.
    function set(uint256 _pid, uint256 _allocPoint, uint16 _depositFeeBP, bool _withUpdate) public onlyOwner {
        require(_depositFeeBP <= 10000, "set: invalid deposit fee basis points");
        require(_depositFeeBP <= 5000, "max 50% fee");
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].depositFeeBP = _depositFeeBP;
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256){
        return (a>b) ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256){
        return (a>b) ? b : a;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {

        uint256 start = max(_from, startBlock);
        uint256 end = min(_to, endBlock);
        if (end > start){
            return end.sub(start).mul(BONUS_MULTIPLIER);
        }else{
            return 0;
        }
    }

    // View function to see pending EGGs on frontend.
    function pendingKafe(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accKafePerShare = pool.accKafePerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
     
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 kafeReward = multiplier.mul(kafePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accKafePerShare = accKafePerShare.add(kafeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accKafePerShare).div(1e12).sub(user.rewardDebt);
    }

    // Update reward variables for all pools. Be careful of gas spending!
    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
     
        if (lpSupply == 0 || pool.allocPoint == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 kafeReward = multiplier.mul(kafePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accKafePerShare = pool.accKafePerShare.add(kafeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accKafePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                safeKafeTransfer(msg.sender, pending);
            }
        }
        // prevent double hop for deposit fee
        uint256 intendedDepAmt = _amount;
        uint256 actualDepAmt = _amount;
        
        if (intendedDepAmt > 0) {

            if (pool.depositFeeBP > 0) {
                uint256 feeAmount = intendedDepAmt.mul(pool.depositFeeBP).div(10000); // 100 = 1%

                if (feeFactor[msg.sender][_pid]>0){
                    feeAmount = feeAmount.mul(feeFactor[msg.sender][_pid]).div(10000);
                }

                pool.lpToken.safeTransferFrom(address(msg.sender), feeAddress, feeAmount);
                intendedDepAmt = intendedDepAmt.sub(feeAmount);
            }

            uint256 balBefore = pool.lpToken.balanceOf(address(this));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), intendedDepAmt);
            actualDepAmt = pool.lpToken.balanceOf(address(this)).sub(balBefore);

            user.amount = user.amount.add(actualDepAmt);
    

        }
        user.rewardDebt = user.amount.mul(pool.accKafePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, actualDepAmt);
    }

    // Withdraw LP tokens from MasterChef.
    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accKafePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            safeKafeTransfer(msg.sender, pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);

        }
        user.rewardDebt = user.amount.mul(pool.accKafePerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 amount = user.amount;
        user.amount = 0;
        user.rewardDebt = 0;
        pool.lpToken.safeTransfer(address(msg.sender), amount);
        emit EmergencyWithdraw(msg.sender, _pid, amount);
    }

    // Safe kafe transfer function, just in case if rounding error causes pool to not have enough EGGs.
    function safeKafeTransfer(address _to, uint256 _amount) internal {
        uint256 kafeBal = kafe.balanceOf(address(this));
        bool transferSuccess = false;
        if (_amount > kafeBal) {
            transferSuccess = kafe.transfer(_to, kafeBal);
        } else {
            transferSuccess = kafe.transfer(_to, _amount);
        }
        require(transferSuccess, "safeKafeTransfer: transfer failed");
    }

    // Update dev address by the previous dev.
    function dev(address _devaddr) public {
        require(msg.sender == devaddr, "dev: wut?");
        devaddr = _devaddr;
        emit SetDevAddress(msg.sender, _devaddr);
    }

    function setFeeAddress(address _feeAddress) public {
        require(msg.sender == feeAddress, "setFeeAddress: FORBIDDEN");
        feeAddress = _feeAddress;
        emit SetFeeAddress(msg.sender, _feeAddress);
    }

    //Pancake has to add hidden dummy pools inorder to alter the emission, here we make it simple and transparent to all.
    function updateEmissionRate(uint256 _kafePerBlock) public onlyOwner {
        massUpdatePools();
        kafePerBlock = _kafePerBlock;
        emit UpdateEmissionRate(msg.sender, _kafePerBlock);
    }


    function drainRewardToken() external onlyOwner {
        uint256 tokenBalance = kafe.balanceOf(address(this));
        kafe.transfer(owner(), tokenBalance);
    }

}
