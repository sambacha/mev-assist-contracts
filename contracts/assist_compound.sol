pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

interface CEth {
function mint() external payable;
function borrow(uint256) external returns (uint256);
function repayBorrow() external payable;
function borrowBalanceCurrent(address) external returns (uint256);
}


interface CErc20 {
function mint(uint256) external returns (uint256);
function borrow(uint256) external returns (uint256);
function borrowRatePerBlock() external view returns (uint256);
function borrowBalanceCurrent(address) external returns (uint256);
function repayBorrow(uint256) external returns (uint256);
}


interface Comptroller {
function markets(address) external returns (bool, uint256);
function enterMarkets(address[] calldata)
external
returns (uint256[] memory);

function getAccountLiquidity(address)
external
view
returns (uint256, uint256, uint256);

function exitMarket(address cToken) external returns (uint);
}

interface PriceOracle {
  function getUnderlyingPrice(address cToken) external view returns (uint);
}

interface CTokenInterface {
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function borrow(uint borrowAmount) external returns (uint);
    function liquidateBorrow(address borrower, uint repayAmount, address cTokenCollateral) external returns (uint);
    function liquidateBorrow(address borrower, address cTokenCollateral) external payable;
    function exchangeRateCurrent() external returns (uint);
    function getCash() external view returns (uint);
    function totalBorrowsCurrent() external returns (uint);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function totalReserves() external view returns (uint);
    function reserveFactorMantissa() external view returns (uint);
    function borrowBalanceCurrent(address account) external returns (uint);

    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function allowance(address, address) external view returns (uint);
    function approve(address, uint) external;
    function transfer(address, uint) external returns (bool);
    function transferFrom(address, address, uint) external returns (bool);
}


