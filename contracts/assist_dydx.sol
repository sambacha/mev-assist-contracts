pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/math/SafeMath.sol";

contract SoloMargin {
    using SafeMath for uint96;
    using SafeMath for uint128;
    using SafeMath for uint256;

    enum ActionType {
        Deposit, // supply tokens
        Withdraw, // borrow tokens
        Transfer, // transfer balance between accounts
        Buy, // buy an amount of some token (externally)
        Sell, // sell an amount of some token (externally)
        Trade, // trade tokens against another account
        Liquidate, // liquidate an undercollateralized or expiring account
        Vaporize, // use excess tokens to zero-out a completely negative account
        Call // send arbitrary data to an address
    }
    enum AssetDenomination { Wei, Par }

    enum AssetReference { Delta, Target }

    struct AccountInfo {
        address owner;
        uint256 number;
    }
    struct ActionArgs {
        ActionType actionType;
        uint256 accountId;
        AssetAmount amount;
        uint256 primaryMarketId;
        uint256 secondaryMarketId;
        address otherAddress;
        uint256 otherAccountId;
        bytes data;
    }
    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }
    struct Index {
        uint96 borrow;
        uint96 supply;
        uint32 lastUpdate;
    }
    struct Rate {
        uint256 value;
    }
    struct TotalPar {
        uint128 borrow;
        uint128 supply;
    }
    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    function getMarketInterestRate(uint256 marketId)
        external
        view
        returns (Rate memory);

    function getMarketTotalPar(uint256 marketId)
        external
        view
        returns (TotalPar memory);

    function getMarketCurrentIndex(uint256 marketId)
        external
        view
        returns (Index memory);

    function getAccountWei(AccountInfo calldata account, uint256 marketId)
        external
        view
        returns (Wei memory);

    function operate(
        AccountInfo[] calldata accounts,
        ActionArgs[] calldata actions
    ) external;
}

library Account {
    struct Info {
        address owner;
        uint256 number;
    }
}

library Types {
    struct Wei {
        bool sign; // true if positive
        uint256 value;
    }

    enum AssetDenomination {
        Wei, // the amount is denominated in wei
        Par // the amount is denominated in par
    }

    enum AssetReference {
        Delta, // the amount is given as a delta from the current value
        Target // the amount is given as an exact number to end up at
    }

    struct AssetAmount {
        bool sign; // true if positive
        AssetDenomination denomination;
        AssetReference ref;
        uint256 value;
    }
}
