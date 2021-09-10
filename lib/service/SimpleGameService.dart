import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightHero.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class SimpleGameService {
  static Future<FightReward> getFightReward(int difficulty) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'simpleGame',
        ConfigModel.getInstance().config(ConfigConstants.simpleGame),
        'simpleGame');
    final function = contract.function('getFightReward');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [BigInt.from(difficulty)],
    );
    return FightReward(result[0] as BigInt, result[1] as BigInt);
  }

  static Future<List<FightHero>> getFightHeroes(int difficulty) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'simpleGame',
        ConfigModel.getInstance().config(ConfigConstants.simpleGame),
        'simpleGame');
    final function = contract.function('getFightHeroes');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [
        EthereumAddress.fromHex(AccountModel.getInstance().account),
        BigInt.from(difficulty)
      ],
    );
    List tokenIds = result[0] as List;
    List fightCounts = result[1] as List;
    List fightRates = result[2] as List;
    List<FightHero> fightHeroes = [];
    for (int index = 0; index < tokenIds.length; index++) {
      int count = (fightCounts[index] as BigInt).toInt();
      int rate = (fightRates[index] as BigInt).toInt();
      if (count > 0 && rate > 0) {
        fightHeroes.add(
          FightHero(
            HeroInfo.fromTokenId(tokenIds[index] as BigInt),
            count,
            rate ~/ 100,
          ),
        );
      }
    }
    return fightHeroes;
  }

  static Future<String> buy(String input, String requestAmount) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'tokenPool',
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
        'tokenPool');
    final buyFunction = contract.function('buy');
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    EthereumAddress ownAddress = await credentials.extractAddress();
    Transaction transaction = Transaction.callContract(
      contract: contract,
      function: buyFunction,
      from: ownAddress,
      value: EtherAmount.inWei(NumberUtil.pow(num: input, exponent: 18)),
      // gasPrice: gasPrice,
      parameters: [NumberUtil.pow(num: requestAmount, exponent: 18)],
    );
    String buyHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('buy', buyHash);
    return buyHash;
  }
}
