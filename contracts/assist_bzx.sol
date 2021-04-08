pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC20/ERC20.sol";

contract IToken is ERC20 {
    function mint(address receiver, uint256 depositAmount)
        external
        returns (uint256);

    function burn(address receiver, uint256 withdrawAmount)
        external
        returns (uint256);

    function mintWithEther(address receiver) external payable returns (uint256);

    function burnToEther(address receiver, uint256 withdrawAmount)
        external
        returns (uint256);

    function loanTokenAddress() external returns (address);
}

contract fulcrumInterface {
    function mintWithEther(address receiver, uint256 maxPriceAllowed)
        external
        payable
        returns (uint256 mintAmount);

    function mint(address receiver, uint256 amount)
        external
        payable
        returns (uint256 mintAmount);

    function burnToEther(
        address receiver,
        uint256 burnAmount,
        uint256 minPriceAllowed
    ) external returns (uint256 loanAmountPaid);
}

interface IBZxLoanToken {
    function transfer(address dst, uint256 amount) external returns (bool);

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function loanTokenAddress() external view returns (address);

    function tokenPrice() external view returns (uint256 price);

    //    function mintWithEther(address receiver) external payable returns (uint256 mintAmount);
    function mint(address receiver, uint256 depositAmount)
        external
        returns (uint256 mintAmount);

    //    function burnToEther(address payable receiver, uint256 burnAmount) external returns (uint256 loanAmountPaid);
    function burn(address receiver, uint256 burnAmount)
        external
        returns (uint256 loanAmountPaid);
}

contract IBZxLoanEther is IBZxLoanToken {
    function mintWithEther(address receiver)
        external
        payable
        returns (uint256 mintAmount);

    function burnToEther(address payable receiver, uint256 burnAmount)
        external
        returns (uint256 loanAmountPaid);
}
