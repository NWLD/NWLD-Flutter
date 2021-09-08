class Chain {
  String name;
  String symbol;
  List<String> rpcList;
  int chainId;

  String configAddress; //配置合约地址

  Chain(this.name, this.symbol, this.chainId);
}

class ChainConstant {
  static const String HT = 'HT';
  static const String BNB = 'BNB';
  static const String CET = 'CET';

  static List<String> supportChainList() {
    List<String> list = [HT, BNB, CET];
    return list;
  }

  static Map<String, Chain> symbolChainMap = {};

  //TODO 这里修改链的配置信息
  static Chain symbolChain(String symbol) {
    if (null != symbolChainMap[symbol]) {
      return symbolChainMap[symbol];
    }
    if (HT == symbol) {
      Chain ht = Chain('Heco Smart Chain', symbol, 128);
      ht.rpcList = ['https://http-mainnet.hecochain.com'];
      symbolChainMap[symbol] = ht;
      return ht;
    }
    if (BNB == symbol) {
      Chain bnb = Chain('Binance Smart Chain', symbol, 56);
      bnb.rpcList = ['https://bsc-dataseed1.binance.org'];
      symbolChainMap[symbol] = bnb;
      return bnb;
    }
    if (CET == symbol) {
      Chain cet = Chain('CoinEx Smart Chain', symbol, 52);
      cet.rpcList = ['https://rpc.coinex.net'];
      cet.configAddress = '0x1d1825326654ff34bF8799164906DD6eB688526d';
      symbolChainMap[symbol] = cet;
      return cet;
    }
    return symbolChain(CET);
  }
}
