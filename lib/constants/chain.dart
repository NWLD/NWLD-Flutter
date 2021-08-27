class Chain {
  String name;
  String symbol;
  List<String> rpcList;
  int chainId;

  Chain(this.name, this.symbol, this.chainId);
}

class ChainConstant {
  static const String HT = 'HT';
  static const String BNB = 'BNB';

  static List<String> supportChainList() {
    List<String> list = ['HT', 'BNB'];
    return list;
  }

  static Chain symbolChain(String symbol) {
    if (HT == symbol) {
      Chain ht = Chain('Heco Smart Chain', symbol, 128);
      ht.rpcList = ['https://http-mainnet.hecochain.com'];
      return ht;
    }
    if (BNB == symbol) {
      Chain bnb = Chain('Binance Smart Chain', symbol, 56);
      bnb.rpcList = ['https://bsc-dataseed1.binance.org'];
      return bnb;
    }
    return null;
  }
}
