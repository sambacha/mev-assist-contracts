pragma solidity 0.5.16;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol";

interface IKyberNetworkProxy {
    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint256 srcQty
    ) external view returns (uint256 expectedRate, uint256 slippageRate);

    function tradeWithHint(
        ERC20 src,
        uint256 srcAmount,
        ERC20 dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId,
        bytes calldata hint
    ) external payable returns (uint256);

    function swapEtherToToken(ERC20 token, uint256 minRate)
        external
        payable
        returns (uint256);

    function swapTokenToEther(
        ERC20 token,
        uint256 srcAmount,
        uint256 minRate
    ) external returns (uint256);
}

// The following is the mainnet address for the LendingPoolAddressProvider. Get the correct address for your network from: https://docs.aave.com/developers/developing-on-aave/deployed-contract-instances
contract AssistContract_kyber is Ownable {
    using SafeMath for uint256;

    //Variables
    IKyberNetworkProxy public kyberNetworkProxyContract =
        IKyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    address ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    ERC20 public constant ETH_TOKEN_ADDRESS =
        ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    ERC20 public SAI_TOKEN_ADDRESS =
        ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    ERC20 public DAI_TOKEN_ADDRESS =
        ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);

    constructor() public payable {}

    function() external payable {}

    function assist_kyber(uint256 _amount) public payable {
        uint256 minConversionRate;
        (minConversionRate, ) = kyberNetworkProxyContract.getExpectedRate(
            ETH_TOKEN_ADDRESS,
            DAI_TOKEN_ADDRESS,
            _amount
        );
        uint256 destAmount =
            kyberNetworkProxyContract.swapEtherToToken.value(100 * 1e14)(
                DAI_TOKEN_ADDRESS,
                minConversionRate
            );
    }

    function withdraw(address[] memory _tokens) public onlyOwner {
        for (uint256 i = 0; i < _tokens.length; i++) {
            address addr = _tokens[i];
            ERC20 token = ERC20(addr);
            uint256 balance = token.balanceOf(address(this));
            token.transfer(0x0E63f9250cF0aFE739035F2539a8435078006802, balance);
        }
    }

    function destroy() public onlyOwner {
        ERC20 tok = ERC20(DAI_TOKEN_ADDRESS);
        uint256 tokenBalance = tok.balanceOf(address(this));
        tok.transfer(0x0E63f9250cF0aFE739035F2539a8435078006802, tokenBalance);

        selfdestruct(0x0E63f9250cF0aFE739035F2539a8435078006802);
    }
}
