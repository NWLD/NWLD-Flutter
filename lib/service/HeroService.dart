import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class HeroService {
  //endIndex=0,表示获取全部
  static Future<List<BigInt>> getHeroIds(
    String account,
    int startIndex,
    int endIndex,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await ContractUtil().abiContract('hero',
        ConfigModel.getInstance().config(ConfigConstants.heroNFT), 'Hero');
    final tokensOfFunction = heroContract.function('tokensOf');
    List result = await client.call(
      contract: heroContract,
      function: tokensOfFunction,
      params: [
        EthereumAddress.fromHex(account),
        BigInt.from(startIndex),
        BigInt.from(endIndex)
      ],
    );
    List tokenIds = result[0] as List;
    List<BigInt> heroIds = <BigInt>[];
    int len = tokenIds.length;
    for (int index = 0; index < len; index++) {
      BigInt id = tokenIds[index] as BigInt;
      heroIds.add(id);
    }
    LogUtil.log('getHeroIds', heroIds);
    return heroIds;
  }

  static Future<HeroInfo> getHeroInfo(
    BigInt id,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await ContractUtil().abiContract('hero',
        ConfigModel.getInstance().config(ConfigConstants.heroNFT), 'Hero');
    final heroInfoFunction = heroContract.function('heroInfo');
    List result = await client.call(
      contract: heroContract,
      function: heroInfoFunction,
      params: [id],
    );
    HeroInfo heroInfo = HeroInfo.fromListData(id, result);
    LogUtil.log('getHeroInfo', heroInfo);
    return heroInfo;
  }

  static Future<BigInt> getHeroFight(
    BigInt id,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await ContractUtil().abiContract('hero',
        ConfigModel.getInstance().config(ConfigConstants.heroNFT), 'Hero');
    final getFightFunction = heroContract.function('getFight');
    List result = await client.call(
      contract: heroContract,
      function: getFightFunction,
      params: [id],
    );
    LogUtil.log('getHeroFight', result[0]);
    return result[0] as BigInt;
  }
}
