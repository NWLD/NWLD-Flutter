import 'package:kingspro/constants/config.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class HeroService {
  //endIndex=0,表示获取全部
  static Future<List<BigInt>> getHeroIds(
    String account,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await ContractUtil().abiContract('pet',
        ConfigModel.getInstance().config(ConfigConstants.petNFT), 'Pet');
    final tokensOfFunction = heroContract.function('tokensOf');
    List result = await client.call(
      contract: heroContract,
      function: tokensOfFunction,
      params: [
        EthereumAddress.fromHex(account)
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
}
