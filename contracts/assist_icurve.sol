pragma solidity 0.5.16;
pragma experimental ABIEncoderV2;

interface ICurveFi {
  function exchange_underlying(
    int128 from, int128 to, uint256 _from_amount, uint256 _min_to_amount
  ) external;
}