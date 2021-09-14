class ConfigConstants {
  //TODO 需要在Config合约中设置以下合约
  static String cashier = 'cashier'; //收款地址
  static String gameToken = 'gameToken'; //游戏代币的合约地址
  static String petNFT = 'petNFT'; //Pet合约地址
  static String petShop = 'petShop'; //Pet购买合约地址
  static String statistics = 'statistics'; //Data统计的合约地址
  static String tokenShop = 'tokenShop'; //代币商店的合约地址
  static String simpleGame = 'simpleGame'; //前3个游戏合约，共用
  static String talkingRoom = 'talkingRoom'; //聊天室合约地址
  static String petUpgrade1 = 'petUpgrade1'; //升级1 使用代币概率升级
  static String petUpgrade2 = 'petUpgrade2'; //升级2 使用同种卡牌升级
  static String petSwitchRole = 'petSwitchRole'; //同一稀有度内切换角色

  //TODO 以下是统计的标签
  static String buyPetCost = 'buyPetCost'; //购买消费
  static String fight1WinCount = 'fight1WinCount'; //战斗1赢的次数
  static String fight2Count = 'fight2Count'; //战斗2参与的次数
  static String fight2WinCount = 'fight2WinCount'; //战斗2赢的次数
  static String fight3Count = 'fight3Count'; //战斗3参与的次数
  static String fight3WinCount = 'fight3WinCount'; //战斗3赢的次数
  static String exp = 'exp'; //经验值
  static String winToken = 'winToken'; //赢取的代币，暂定资金池卖出量由赢取代币控制
  static String updatePetCost = 'updatePetCost'; //升级消费
  static String updatePetCount = 'updatePetCount'; //升级次数
  static String updatePetFee = 'updatePetFee'; //升级手续费
  static String switchPetFee = 'switchPetFee'; //切换手续费
  static String switchPetCount = 'switchPetCount'; //切换次数

  static String gameTokenSymbol = 'NWLD';
  static String deadAddress = "0x000000000000000000000000000000000000dEaD";
}
