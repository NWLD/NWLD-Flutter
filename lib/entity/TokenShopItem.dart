class TokenShopItem {
  TokenShopItem({
    this.amount,
    this.price,
    this.qty,
    this.soldCount,
    this.bought,
  });

  BigInt amount;
  int qty;
  int soldCount;
  BigInt price;
  bool bought;
}
