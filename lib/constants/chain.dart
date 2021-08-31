class Chain {
  String name;
  String symbol;
  List<String> rpcList;
  int chainId;

  String gameTokenAddress; //游戏代币合约地址
  String gameTokenSymbol; //游戏代币符号

  String heroNftAddress;//英雄NFT合约地址
  String shopAddress;//英雄NFT商店合约地址

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
      ht.gameTokenAddress = '0xFE6133e86fb4d5811f2e6881c2E25567B45b60B6';
      ht.gameTokenSymbol = 'LOKS';
      ht.heroNftAddress = '0xd55A9B1d770998687fA98FDAd828D03A2fA3F870';
      ht.shopAddress = '0x1A8236c08be629c45Df45E0D371380f7A8833717';
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
