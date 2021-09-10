import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightHero.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
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

  static Future<String> fight(BigInt tokenId, int difficulty, int count) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'simpleGame',
        ConfigModel.getInstance().config(ConfigConstants.simpleGame),
        'simpleGame');
    String fun = difficulty == 3
        ? 'fight3'
        : difficulty == 2
            ? 'fight2'
            : 'fight1';
    LogUtil.log('fight', fun);
    final function = contract.function(fun);
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    EthereumAddress ownAddress = await credentials.extractAddress();

    //手续费价格
    print('getGasPrice');
    EtherAmount gasPrice = await client.getGasPrice();
    print(gasPrice);

    Transaction transaction = Transaction.callContract(
      contract: contract,
      function: function,
      from: ownAddress,
      gasPrice: gasPrice,
      parameters: [tokenId, BigInt.from(count)],
    );

    BigInt maxGas = await client.estimateGas(
      sender: transaction.from,
      to: transaction.to,
      data: transaction.data,
      value: transaction.value,
      gasPrice: transaction.gasPrice,
    );
    //1.2倍估算的gas，避免交易失败
    maxGas = maxGas * BigInt.from(120) ~/ BigInt.from(100);
    print(maxGas);

    transaction = transaction.copyWith(maxGas: maxGas.toInt());

    String fightHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('fightHash', fightHash);
    return fightHash;
  }

  static Future<List<int>> getFightResults(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'simpleGame',
        ConfigModel.getInstance().config(ConfigConstants.simpleGame),
        'simpleGame');
    final function = contract.function('getFightResults');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [tokenId],
    );
    List list = result[0] as List;
    List<int> results = [];
    for (int index = 0; index < list.length; index++) {
      results.add((list[index] as BigInt).toInt());
    }
    LogUtil.log('getFightResults', results);
    return results;
  }
}
