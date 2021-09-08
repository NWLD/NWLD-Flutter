class ConfigConstants {
  //TODO 需要在Config合约中设置以下合约
  static String gameToken = 'gameToken'; //游戏代币的合约地址
  static String gameTokenSymbol = 'gameTokenSymbol';
  static String cashier = 'cashier'; //收款地址
  static String heroNFT = 'heroNFT'; //Hero合约地址
  static String heroShop = 'heroShop'; //Hero购买合约地址
  static String statistics = 'statistics'; //Data统计的合约地址

  //TODO 以下是统计的标签
  static String buyHeroCost = 'buyHeroCost'; //购买英雄消费
  static String fight1WinCount = 'fight1WinCount'; //战斗1赢的次数
  static String fight2Count = 'fight2Count'; //战斗2参与的次数
  static String fight2WinCount = 'fight2WinCount'; //战斗2赢的次数
  static String fight3Count = 'fight3Count'; //战斗3参与的次数
  static String fight3WinCount = 'fight3WinCount'; //战斗3赢的次数
  static String exp = 'exp'; //经验值
  static String winToken = 'winToken'; //赢取的代币，暂定资金池卖出量由赢取代币控制
  static String updateHeroCost = 'updateHeroCost'; //升级英雄消费
  static String updateHeroCount = 'updateHeroCount'; //升级英雄次数
  static String updateHeroFee = 'updateHeroFee'; //升级英雄手续费
  static String switchHeroFee = 'switchHeroFee'; //切换英雄手续费
  static String switchHeroCount = 'switchHeroCount'; //切换英雄次数
}
