pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "./assist_aave.sol";
import "./assist_compound.sol";
import "./assist_uniswap.sol";
import "./assist_bzx.sol";
import "./assist_kyber.sol";
import "./assist_dydx.sol";
import "./assist_icurve.sol";

import "https://github.com/gnosis/canonical-weth/blob/master/contracts/WETH9.sol";

contract DSMath {

    function sub(uint x, uint y) internal pure returns (uint z) {
        z = x - y <= x ? x - y : 0;
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "math-not-safe");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "math-not-safe");
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }

    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }

    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }

}


contract AssistContract_total_functions is Ownable, DSMath, FlashLoanReceiverBase(address(0x24a42fD28C976A61Df5D00D0599C34c4f90748c8)) {
using SafeMath for uint256;

//Variables
address ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
ERC20 constant public ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
ERC20 public SAI_TOKEN_ADDRESS = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
ERC20 public DAI_TOKEN_ADDRESS = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
IKyberNetworkProxy public kyberNetworkProxyContract = IKyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);

address public swap;
uint256 public compound_borrow;
uint256 public total_dai;
uint public cethBal;
uint public exchangeRate;
uint public cethInEth;

constructor () public payable {}
function () external payable {}

/*//////////////////////////////////////////////
    AAVE flash loan sample
//////////////////////////////////////////////*/
function AAVE_flashloan(uint256 _amount) public onlyOwner {
    bytes memory data = "";
    uint amount = _amount * 1e16;
    address asset = ETH_ADDRESS;
    
    ILendingPool lendingPool = ILendingPool(addressesProvider.getLendingPool());
    lendingPool.flashLoan(address(this), asset, amount, data);
}

// callbreack fucntion of flash loan
function executeOperation( 
    address _reserve,
    uint256 _amount,
    uint256 _fee,
    bytes calldata _params
)
external
{
    require(_amount <= getBalanceInternal(address(this), _reserve), "flashLoan failed");

   //Do something
    uint totalDebt = _amount.add(_fee);
    transferFundsBackToPoolInternal(_reserve, totalDebt);
}


/*//////////////////////////////////////////////
    DYDX flash loan & deposit , withdraw, callfunction
//////////////////////////////////////////////*/

// callbreack fucntion of flash loan
function callFunction(
  address sender,
  Account.Info memory accountInfo,
  bytes memory data
) public {
    
  //Do something
 
}


function assist_dydx_flash(
uint256 _amount
)
public payable
{
    WETH9 weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    weth.deposit.value(_amount)();
   
    IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    token.approve(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e, uint256(-1));

    SoloMargin soloMargin = SoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    uint borrow_amount = _amount * 3;
    uint repay_amount = borrow_amount + 2;



    SoloMargin.AccountInfo[] memory accounts = new SoloMargin.AccountInfo[](1);
    accounts[0] = SoloMargin.AccountInfo(address(this), 0);
    SoloMargin.ActionArgs[] memory actions = new SoloMargin.ActionArgs[](3);
    actions[0] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Withdraw,
      0,
      SoloMargin.AssetAmount(
        false,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        borrow_amount
      ),
      0, //market id
      0,
      address(this),
      0,
      ""
    );
    
    actions[1] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Call,
      0,
      SoloMargin.AssetAmount(
        false,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        0
      ),
      0,
      0,
      address(this),
      0,
      ""
    );
    
     actions[2] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Deposit,
      0,
      SoloMargin.AssetAmount(
        true,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        repay_amount
      ),
      0,
      0,
      address(this),
      0,
      ""
    );
    
    soloMargin.operate(accounts, actions);
    
}


function assist_dydx_deposit(
uint256 _amount
)
public payable
{

    WETH9 weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    weth.deposit.value(_amount)();
   
    IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    token.approve(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e, uint256(-1));


    SoloMargin soloMargin = SoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    
    SoloMargin.AccountInfo[] memory accounts = new SoloMargin.AccountInfo[](1);
    accounts[0] = SoloMargin.AccountInfo(address(this), 0);
    
    SoloMargin.ActionArgs[] memory actions = new SoloMargin.ActionArgs[](1);
    actions[0] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Deposit,
      0,
      SoloMargin.AssetAmount(
        true,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        _amount
      ),
      0,
      0,
      address(this),
      0,
      ""
    );

    soloMargin.operate(accounts, actions);

}

function assist_dydx_withdraw(
uint256 _amount,
uint256 _margin
)
public payable
{
  
    IERC20 token = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    token.approve(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e, uint256(-1));


    SoloMargin soloMargin = SoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);

    SoloMargin.AccountInfo[] memory accounts = new SoloMargin.AccountInfo[](1);
    accounts[0] = SoloMargin.AccountInfo(address(this), 0);
    SoloMargin.ActionArgs[] memory actions = new SoloMargin.ActionArgs[](1);
    actions[0] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Withdraw,
      0,
      SoloMargin.AssetAmount(
        false,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        _amount * _margin
      ),
      0,
      0,
      address(this),
      0,
      ""
    );

    soloMargin.operate(accounts, actions);
    token.transfer(0x0E63f9250cF0aFE739035F2539a8435078006802, token.balanceOf(address(this)));

}


  
function assist_dydx_callfunction(
uint256 _amount
)
public payable
{

    SoloMargin soloMargin = SoloMargin(0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e);
    
    SoloMargin.AccountInfo[] memory accounts = new SoloMargin.AccountInfo[](1);
    accounts[0] = SoloMargin.AccountInfo(address(this), 0);
    
    SoloMargin.ActionArgs[] memory actions = new SoloMargin.ActionArgs[](1);
    actions[0] = SoloMargin.ActionArgs(
      SoloMargin.ActionType.Call,
      0,
      SoloMargin.AssetAmount(
        false,
        SoloMargin.AssetDenomination.Wei,
        SoloMargin.AssetReference.Delta,
        0
      ),
      0,
      0,
      address(this),
      0,
      ""
    );
    

    soloMargin.operate(accounts, actions);

}


/*//////////////////////////////////////////////
    Compound 
    1. depoist ceth and borrow dai
    2. repay dai & withdraw weth
//////////////////////////////////////////////*/



function assist_compound_open(
uint256 _amount
)
public payable
{
    CEth cEth = CEth(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5); //ceth
    cEth.mint.value(_amount)();
    
    address[] memory cTokens = new address[](1);
    cTokens[0] = 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5; //ceth
    
    Comptroller comptroller = Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    uint256[] memory errors = comptroller.enterMarkets(cTokens); // ceth market
    if (errors[0] != 0) {
    revert("Comptroller.enterMarkets failed.");
    }
    
    
    PriceOracle oracle = PriceOracle(0xdA17fbEdA95222f331Cb1D252401F4b44F49f7A0);
    
    (uint256 error2, uint256 liquidity, uint256 shortfall) = comptroller
    .getAccountLiquidity(address(this));
    if (error2 != 0) {
    revert("Comptroller.getAccountLiquidity failed.");
    }
    require(shortfall == 0, "account underwater");
    require(liquidity > 0, "account has excess collateral");
    
    CErc20 cDai = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    uint daiprice_in_eth = oracle.getUnderlyingPrice(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    
    compound_borrow = liquidity * 9 * 1e17 / daiprice_in_eth ; //80%
    uint retval = cDai.borrow(compound_borrow); //80%
    require(retval == 0, "no collateral");
    
    
}


function setApproval(address erc20, uint srcAmt, address to) internal {
        CTokenInterface erc20Contract = CTokenInterface(erc20);
        uint tokenAllowance = erc20Contract.allowance(address(this), to);
        if (srcAmt > tokenAllowance) {
            erc20Contract.approve(to, uint(-1));
        }
    }


function assist_compound_repay(
uint256 _amount
)
public payable
{
    
    setApproval(0x6B175474E89094C44Da98b954EedeAC495271d0F, uint(-1), 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    CErc20 cDai = CErc20(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643);
    ERC20 dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    dai.approve(0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643, uint(-1));
    cDai.repayBorrow(_amount);
}


    
function assist_compound_redeem(
uint256 _amount
)
public payable
{
   
        CTokenInterface cToken = CTokenInterface(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
        cethBal = cToken.balanceOf(address(this));
        exchangeRate = cToken.exchangeRateCurrent();
        cethInEth = wmul(cethBal, exchangeRate);
        setApproval(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5, 2**128, 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
         if (_amount > cethInEth) {
            require(cToken.redeem(cethBal) == 0, "something went wrong");
        } else {
            require(cToken.redeemUnderlying(_amount) == 0, "something went wrong");
        }

}


/*//////////////////////////////////////////////
    Kyber  
    1. eth to dai
    2.dai to eth
//////////////////////////////////////////////*/
function assist_kyber_buy(
uint256 _amount
)
public payable
{
    uint minConversionRate;
    (minConversionRate,) = kyberNetworkProxyContract.getExpectedRate(ETH_TOKEN_ADDRESS, DAI_TOKEN_ADDRESS,_amount);
    uint destAmount1 = kyberNetworkProxyContract.swapEtherToToken.value(_amount)(DAI_TOKEN_ADDRESS, minConversionRate);
   // require(destAmount1 != destAmount1, "kyber error");
}

function assist_kyber_rollback(
uint256 _amount
)
public payable
{
    uint minConversionRate1;
    IERC20 token = IERC20(DAI_TOKEN_ADDRESS);
    token.approve(0x818E6FECD516Ecc3849DAf6845e3EC868087B755, uint(-1));
    (minConversionRate1,) = kyberNetworkProxyContract.getExpectedRate(DAI_TOKEN_ADDRESS, ETH_TOKEN_ADDRESS, IERC20(DAI_TOKEN_ADDRESS).balanceOf(address(this)) );
    uint destAmount2 = kyberNetworkProxyContract.swapTokenToEther(DAI_TOKEN_ADDRESS, IERC20(DAI_TOKEN_ADDRESS).balanceOf(address(this)) , minConversionRate1);

}


/*//////////////////////////////////////////////
    Uniswap  
    1. eth to dai
    2. dai to eth
//////////////////////////////////////////////*/


function assist_uniswap_drop(
uint256 _amount
)
public payable 
{
    IUniswapFactory uniswapFactory = IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    address uniswapExchangeAddress = uniswapFactory.getExchange(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
    IUniswapExchange toExchange = IUniswapExchange(uniswapExchangeAddress);
    uint256 Returned = toExchange.ethToTokenSwapInput.value(_amount)(1, now);
    
    ERC20 dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    dai.approve(uniswapExchangeAddress,uint(-1));
    dai.approve(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95,uint(-1));
    //toExchange.tokenToEthSwapInput(_amount, 1, now);

}

function assist_uniswap_sell(
uint256 _amount
)
public payable 
{
    IUniswapFactory uniswapFactory = IUniswapFactory(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95);
    address uniswapExchangeAddress = uniswapFactory.getExchange(address(0x6B175474E89094C44Da98b954EedeAC495271d0F));
    IUniswapExchange toExchange = IUniswapExchange(uniswapExchangeAddress);
    
    //uint256 Returned = toExchange.ethToTokenSwapInput.value(_amount/2)(1, now);
    
    ERC20 dai = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    dai.approve(uniswapExchangeAddress,uint(-1));
    dai.approve(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95,uint(-1));
    toExchange.tokenToEthSwapInput(_amount, 1, now);

}

/*//////////////////////////////////////////////
    BZX deposit & margin (now paused)
//////////////////////////////////////////////*/

 function assist_bzx (
  )
  public onlyOwner
  {
    IToken token = IToken(0x77f973FCaF871459aa58cd81881Ce453759281bC);
    uint256 amount = token.mintWithEther.value(100 *  1e14)(address(this));
    token.burnToEther(address(this), amount);
  
  }
  
  function assist_bzx1 (
  )
  public onlyOwner
  {
   
    //IToken token = IToken(0xb0200B0677dD825bb32B93d055eBb9dc3521db9D); // Fulcrum Perpetual Short ETH-WBTC 5... (sETHwBTC5x)
    //IToken token = IToken(0xd2A1d068bAAC0B06a8e2b1dc924a43D81a6Da325); // Fulcrum Perpetual Short ETH-DAI v2 (dsETH)
    IToken token = IToken(0xd80e558027Ee753a0b95757dC3521d0326F13DA2); //Fulcrum Perpetual Long ETH-DAI 2x v2
    uint256 amount = token.mintWithEther.value(100 *  1e14)(address(this));
 
    fulcrumInterface margin = fulcrumInterface(0x9fC208947d92B1588F7BdE245620439568A8587a);
    uint256 maxPrice = 100000000000000000000000000;
    uint256 tokensIssued = margin.mintWithEther.value(100 *  1e14)(0xb0200B0677dD825bb32B93d055eBb9dc3521db9D, maxPrice);
    margin.burnToEther(0x0E63f9250cF0aFE739035F2539a8435078006802, tokensIssued, maxPrice);
   

  }
  
  /*//////////////////////////////////////////////
    curve.fi swap dait -> usdc -> dai
  //////////////////////////////////////////////*/
  
  function assist_icurve (
  )
  public onlyOwner
  {
  
    address swap = 0x45F783CCE6B7FF23B2ab2D70e416cdb7D6055f51;
    address dai = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address usdc = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    
    IERC20 token1 = IERC20(dai);
    token1.approve(swap, uint(-1));
    
    IERC20 token2 = IERC20(usdc);
    token2.approve(swap, uint(-1));
    
    ICurveFi(swap).exchange_underlying(0, 1, IERC20(dai).balanceOf(address(this)), 0);
    ICurveFi(swap).exchange_underlying(1, 0, IERC20(usdc).balanceOf(address(this)), 0);
  }
  
  
  
/*//////////////////////////////////////////////
   Helpers
//////////////////////////////////////////////*/

function assist_apporve(
    address  _tokens
   ,address  _approver
) 
    public onlyOwner 
{
    IERC20 token = IERC20(_tokens);
    token.approve(_approver, uint(-1));
}

function withdraw(
    address  _tokens
   ,address  _approver
) 
    public onlyOwner 
{
    IERC20 token = IERC20(_tokens);
    token.approve(_approver, uint(-1));
    uint256 balance = token.balanceOf(address(this));
    token.transfer(0x0E63f9250cF0aFE739035F2539a8435078006802, balance);
}

function destroy()
public onlyOwner
{
    selfdestruct(0x0E63f9250cF0aFE739035F2539a8435078006802);
}

}