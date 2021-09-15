class TokenPoolInfo {
  BigInt tokenBalance;
  BigInt ethBalance;
  BigInt buyPrice;
  BigInt sellPrice;

  TokenPoolInfo(
    this.tokenBalance,
    this.ethBalance,
    this.sellPrice,
    this.buyPrice,
  );
}
