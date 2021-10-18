// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract SpaceRouter {
	// address payable spcAddress;
	// address payable liquidityAddress;
	mapping(address => uint) ethDeposits;

	LiquidityPool private liquidityPool;
	SPCContract private spcContract;

	constructor(LiquidityPool _liquidityPool, SPCContract _spcContract) {
		liquidityPool = _liquidityPool;
		spcContract = _spcContract;
	}

	receive() external payable {    }


	function _addLiquidity(
		uint amountADesired,
		uint amountBDesired
	) internal view returns (uint amountA, uint amountB) {
		(uint reserveA, uint reserveB, ) = liquidityPool.getReserves();
		if (reserveA == 0 && reserveB == 0) {
			(amountA, amountB) = (amountADesired, amountBDesired);
		} else {
			uint amountBOptimal = quote(amountADesired, reserveA, reserveB);
			if (amountBOptimal <= amountBDesired) {
				(amountA, amountB) = (amountADesired, amountBOptimal);
			} else {
				uint amountAOptimal = quote(amountBDesired, reserveB, reserveA);
				assert(amountAOptimal <= amountADesired);
				(amountA, amountB) = (amountAOptimal, amountBDesired);
			}
		}
	}

	function addLiquidity(
		uint256 amountTokenDesired,
		address to
	) external payable returns (uint amountToken, uint amountETH, uint liquidity) {
		(amountToken, amountETH) = _addLiquidity(
			amountTokenDesired,
			msg.value
		);

		spcContract.transferFrom(msg.sender, address(liquidityPool), amountToken);

		(bool sent, ) = address(liquidityPool).call{value: amountETH}("");
		require(sent, 'SpaceRouter: Error sending eth to LP');
		
		liquidity = liquidityPool.mint(to);

		// refund dust eth, if any
		if (msg.value > amountETH) ethDeposits[msg.sender] += (msg.value - amountETH);
	}

	// on remove liquidity, we burn given tokens and credit sender
	function removeLiquidity(
		uint liquidity,
		uint amountTokenMin,
		uint amountETHMin,
		address to,
		uint deadline
	) external returns (uint amountToken, uint amountETH) {
		liquidityPool.transferFrom(msg.sender, address(liquidityPool), liquidity);
		(amountToken, amountETH) = liquidityPool.burn(to);

		require(amountToken >= amountTokenMin, 'SpaceRouter: INSUFFICIENT TOKEN AMOUNT');
		require(amountETH >= amountETHMin, 'SpaceRouter: INSUFFICIENT ETH AMOUNT');

		safeTransfer(address(spcContract), to, amountToken);
		safeTransferETH(to, amountETH);
	}

	function swapExactETHForSpc(
        uint amountOutMin,
        address to,
        uint deadline
    )
        external
        payable
    {
        uint amountIn = msg.value;

		uint balanceBefore = spcContract.balanceOf(to);

		(bool sent,) = address(liquidityPool).call{value: amountIn}("");
		require(sent, 'SpaceRouter: Error sending eth to LP');

		uint amountInput;
		uint amountOutput;

		{
			(uint _spcReserve, uint _ethReserve, ) = liquidityPool.getReserves();
			
			amountInput = address(liquidityPool).balance - _ethReserve;

			require(amountInput > 0, 'SpaceRouter: INSUFFICIENT_INPUT_AMOUNT');
			require(_ethReserve > 0 && _spcReserve > 0, 'SpaceRouter: INSUFFICIENT_INPUT_AMOUNT');

			uint amountInWithFee = amountInput * 997;
			uint numerator = amountInWithFee * _spcReserve;
			uint denominator = (_ethReserve * 1000) + amountInWithFee;
			amountOutput = numerator / denominator;

			liquidityPool.swap(uint(0), amountOutput, to, new bytes(0));
		}

		require(spcContract.balanceOf(to) - (balanceBefore) >= amountOutMin);
    }

	function swapExactSpcForETH(
        uint amountIn,
		uint amountOutMin,
        address to,
        uint deadline
    )
        external
        payable
    {
		uint balanceBefore = spcContract.balanceOf(to);

		safeTransferFrom(address(spcContract), msg.sender, address(liquidityPool), amountIn);

		uint amountInput;
		uint amountOutput;

		{
			(uint _spcReserve, uint _ethReserve, ) = liquidityPool.getReserves();
			
			amountInput = spcContract.balanceOf(address(liquidityPool)) - _spcReserve;

			require(amountInput > 0, 'SpaceRouter: INSUFFICIENT_INPUT_AMOUNT');
			require(_ethReserve > 0 && _spcReserve > 0, 'SpaceRouter: INSUFFICIENT_INPUT_AMOUNT');

			uint amountInWithFee = amountInput * 997;
			uint numerator = amountInWithFee * _ethReserve;
			uint denominator = (_spcReserve * 1000) + (amountInWithFee);
			amountOutput = numerator / denominator;

			liquidityPool.swap(amountOutput, uint(0), to, new bytes(0));
		}

		require(spcContract.balanceOf(to) - balanceBefore >= amountOutMin);
    }

	// given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
	function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
		require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
		require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
		amountB = amountA * (reserveB) / reserveA;
	}

	function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }

	function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
		require(tokenA != tokenB, 'SPRouter: IDENTICAL_ADDRESSES');
		(token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
		require(token0 != address(0), 'SPRouter: ZERO_ADDRESS');
	}

}


interface LiquidityPool {
	function getReserves() external view returns (uint _spcReserve, uint _ethReserve, uint _blockTimestampLast);
	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);
	function burn(address to) external returns (uint amount0, uint amount1);
	function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
	function mint(address to) external payable returns (uint liquidity);
}

interface SPCContract {
	function balanceOf(address account) external view returns (uint256);
	function transferFrom(
		address sender,
		address recipient,
		uint256 amount
	) external returns (bool);
}