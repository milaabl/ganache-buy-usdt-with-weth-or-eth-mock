pragma solidity ^0.8.1;

interface IUniV3SwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external;
}

contract Test {
    event Success(uint256 amountOut);

    function buyUSDT() external payable returns (uint256 amountOut) {
        IUniV3SwapRouter uniV3Router = IUniV3SwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        IWETH weth = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

        weth.deposit{value: 10 ether}();

        weth.approve(address(uniV3Router), 10 ether);

        (amountOut) = uniV3Router.exactInputSingle{value: 10 ether}(IUniV3SwapRouter.ExactInputSingleParams({
            recipient: msg.sender,
            tokenIn: address(weth),
            tokenOut: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            deadline: block.timestamp + 1000,
            amountIn: 10 ether,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0,
            fee: 3000
        }));

        emit Success(amountOut);

        require(amountOut > 0, "Not enough!");
    }
}
