import 'package:kingspro/constants/config.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class ConfigService {
  static Future<Map<String, String>> getConfigs() async {
    LogUtil.log('getConfigs', 'start');
    Map<String, String> map = {};
    final client = Web3Util().web3Client();
    final configContract = await ContractUtil().abiContract('config',
        SettingsModel.getInstance().currentChain().configAddress, 'config');
    final labelListAddressFunction =
        configContract.function('labelListAddress');
    List result = await client.call(
      contract: configContract,
      function: labelListAddressFunction,
      params: [
        [
          ConfigConstants.gameToken,
          ConfigConstants.heroNFT,
          ConfigConstants.heroShop,
          ConfigConstants.statistics,
          ConfigConstants.tokenPool,
          ConfigConstants.simpleGame
        ]
      ],
    );
    List addressList = result[0] as List;
    map[ConfigConstants.gameToken] =
        (addressList[0] as EthereumAddress).hexEip55;
    map[ConfigConstants.heroNFT] = (addressList[1] as EthereumAddress).hexEip55;
    map[ConfigConstants.heroShop] =
        (addressList[2] as EthereumAddress).hexEip55;
    map[ConfigConstants.statistics] =
        (addressList[3] as EthereumAddress).hexEip55;
    map[ConfigConstants.tokenPool] =
        (addressList[4] as EthereumAddress).hexEip55;
    map[ConfigConstants.simpleGame] =
        (addressList[5] as EthereumAddress).hexEip55;
    LogUtil.log('getConfigs', map);
    return map;
  }
}
