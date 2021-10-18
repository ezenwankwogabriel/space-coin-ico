// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import './LiquidityPoolToken.sol';
import './libraries/Math.sol';
import './SpaceCoinToken.sol';

contract LiquidityPool is LPToken {
    
    uint public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public feeTo;
    address public feeToSetter;

    SpaceCoin spcToken;

    uint private spcReserve;
    uint private ethReserve;
    uint private blockTimestampLast;

    uint public kLast;

    uint private unlocked;

    mapping(address => uint) ethBalanceOf;

    modifier lock() {
        require(unlocked == 1, "LP Locked");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(SELECTOR, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'LP: TRANSFER_FAILED');
    }

    function getReserves() public view returns (uint _spcReserve, uint _ethReserve, uint _blockTimestampLast) {
        _spcReserve = spcReserve;
        _ethReserve = ethReserve;
        _blockTimestampLast = blockTimestampLast;
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);

    receive() external payable {}

    function initialize(SpaceCoin _spcToken) public {
        spcToken = _spcToken;
    }

    function _update(uint balance0, uint balance1, uint _spcReserve, uint _ethReserve) private {
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        
        spcReserve = uint(balance0);
        ethReserve = uint(balance1);
        blockTimestampLast = blockTimestamp;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, 'LP: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, 'LP: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint _spcReserve, uint _ethReserve) private returns (bool feeOn) {
        address _feeTo = feeTo;
        feeOn = _feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = Math.sqrt(uint(_spcReserve) * _ethReserve);
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint numerator = totalSupply() * (rootK - rootKLast);
                    uint denominator = (rootK * 5) + rootKLast;
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(_feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function mint(address to) external payable lock returns (uint liquidity) {
        (uint _spcReserve, uint _ethReserve, ) = getReserves();
        
        uint balance0 = spcToken.balanceOf(address(this)); // balance of this contract on spcToken
        uint balance1 = address(this).balance;

        uint amount0 = balance0 - _spcReserve;
        uint amount1 = balance1 - _ethReserve;

        bool feeOn = _mintFee(_spcReserve, _ethReserve);
        uint _totalSupply = totalSupply();

        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - (MINIMUM_LIQUIDITY);
        } else {
            liquidity = Math.min((amount0 - _totalSupply) / _spcReserve, (amount1 - _totalSupply) / _ethReserve);
        }
        require(liquidity > 0, 'LP: INSUFFICIENT_LIQUIDITY_MINTED');
        _mint(to, liquidity);

        _update(balance0, balance1, _spcReserve, _ethReserve);
        if (feeOn) kLast = uint(spcReserve) * ethReserve; // reserve0 and reserve1 are up-to-date
        emit Mint(msg.sender, amount0, amount1);
    }

    function burn(address to) external lock returns (uint amount0, uint amount1) {
        (uint _spcReserve, uint _ethReserve,) = getReserves(); // gas savings
        SpaceCoin _spcToken = spcToken;                                // gas savings
        uint spcBalance = _spcToken.balanceOf(address(this));
        uint ethBalance = address(this).balance;
        uint liquidity = balanceOf(address(this)); // peripheral contract transfers amount of liquidity to be burnt to this contract

        bool feeOn = _mintFee(_spcReserve, _ethReserve);
        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        
        amount0 = liquidity * (spcBalance) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity * (ethBalance) / _totalSupply; // using balances ensures pro-rata distribution
        
        require(amount0 > 0 && amount1 > 0, 'LP: INSUFFICIENT_LIQUIDITY_BURNED');
        
        _burn(address(this), liquidity);
        _safeTransfer(address(_spcToken), to, amount0);
        ethBalanceOf[to] += amount1;
        
        uint balance0 = _spcToken.balanceOf(address(this));
        uint balance1 = address(this).balance;

        _update(balance0, balance1, address(_spcToken).balance, address(this).balance);
        if (feeOn) kLast = uint(_spcReserve) * (_ethReserve); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

    function  withdrawEth(address to) public {
        uint balance = ethBalanceOf[msg.sender];
        ethBalanceOf[msg.sender] = 0;
        (bool sent, ) = to.call{value: balance}("");
        require(sent, "LP: Withdraw not successful");
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        require(amount0Out > 0 || amount1Out > 0, 'LP: INSUFFICIENT_OUTPUT_AMOUNT');

        (uint _spcReserve, uint _ethReserve, ) = getReserves();

        require(amount0Out < _spcReserve && amount1Out < _ethReserve, 'LP: INSUFFICIEENT_LIQUIDITY');

        uint balance0;
        uint balance1;
        {
            SpaceCoin _spcToken = spcToken;

            require(to != address(_spcToken), 'Uniswap: INVALID_TO');
            if (amount0Out > 0) _safeTransfer(address(_spcToken), to, amount0Out);
            if (amount1Out > 0) ethBalanceOf[to] += amount1Out;

            balance0 = _spcToken.balanceOf(address(this));
            balance1 = address(this).balance;
        }

        uint amount0In = balance0 > _spcReserve - amount0Out ? balance0 - (_spcReserve - amount0Out) : 0;
        uint amount1In = balance1 > _ethReserve - amount1Out ? balance1 - (_ethReserve - amount1Out) : 0;

        require(amount0In > 0 || amount1In > 0, 'LP: INSUFFICIENT_INPUT_AMOUNT');
        {
            uint balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint balance1Adjusted = (balance1 * 1000) - (amount1In * 3);

            require(balance0Adjusted * balance1Adjusted >= uint(_spcReserve) * _ethReserve, 'LP: k');

            _update(balance0, balance1, _spcReserve, _ethReserve);
        }
    }

    // force reserves to match balances
    function sync() external lock {
        _update(spcToken.balanceOf(address(this)), address(this).balance, spcReserve, ethReserve);
    }

}
