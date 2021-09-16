class Chain {
  String name;
  String symbol;
  List<String> rpcList;
  int chainId;
  BigInt gasPrice = BigInt.from(1000000000);

  String configAddress; //配置合约地址

  Chain(this.name, this.symbol, this.chainId);
}

class ChainConstant {
  static const String HT = 'HT';
  static const String BNB = 'BNB';
  static const String CET = 'CET';
  static const String HOO = 'HOO';
  static const String OKT = 'OKT';

  static List<String> supportChainList() {
    List<String> list = [OKT, HOO];
    return list;
  }

  static Map<String, Chain> symbolChainMap = {};

  //TODO 这里修改链的配置信息
  static Chain symbolChain(String symbol) {
    if (null != symbolChainMap[symbol]) {
      return symbolChainMap[symbol];
    }
    if (OKT == symbol) {
      Chain okt = Chain('OKex Smart Chain', symbol, 66);
      okt.rpcList = ['https://exchainrpc.okex.org'];
      okt.configAddress = '0x4EBcD18d70527774a765fAdeCD8C30205EcB8eC8';
      okt.gasPrice = BigInt.from(300000000);
      symbolChainMap[symbol] = okt;
      return okt;
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
      cet.configAddress = '0x0D21dF9D4f1e507935187a019eCb9bfdEFEf76fd';
      symbolChainMap[symbol] = cet;
      return cet;
    }
    if (HOO == symbol) {
      Chain hoo = Chain('HOO Smart Chain', symbol, 70);
      hoo.rpcList = ['https://http-mainnet.hoosmartchain.com'];
      hoo.configAddress = '0x60d4f8b0900b7a79fC8dD752157648f9d32fE9E8';
      symbolChainMap[symbol] = hoo;
      return hoo;
    }
    return symbolChain(OKT);
  }
}
