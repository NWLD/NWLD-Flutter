import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightPet.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class SimpleGameService {
  static Future<DeployedContract> simpleGameContract() async {
    final contract = await ContractUtil.abiContract(
        'simpleGame',
        ConfigModel.getInstance().config(ConfigConstants.simpleGame),
        'simpleGame');
    return contract;
  }

  static Future<FightReward> getFightReward(int difficulty) async {
    final client = Web3Util().web3Client();
    final contract = await simpleGameContract();
    final function = contract.function('getFightReward');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [BigInt.from(difficulty)],
    );
    return FightReward(result[0] as BigInt, result[1] as BigInt);
  }

  static Future<List<FightPet>> getFightHeroes(int difficulty) async {
    final client = Web3Util().web3Client();
    final contract = await simpleGameContract();
    final function = contract.function('getFightPets');
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
    List<FightPet> fightHeroes = [];
    for (int index = 0; index < tokenIds.length; index++) {
      int count = (fightCounts[index] as BigInt).toInt();
      int rate = (fightRates[index] as BigInt).toInt();
      if (count > 0 && rate > 0) {
        fightHeroes.add(
          FightPet(
            PetInfo.fromTokenId(tokenIds[index] as BigInt),
            count,
            rate ~/ 100,
          ),
        );
      }
    }
    return fightHeroes;
  }

  static Future<Transaction> fight(
    BigInt tokenId,
    int difficulty,
    int count,
  ) async {
    final contract = await simpleGameContract();
    String fun = difficulty == 3
        ? 'fight3'
        : difficulty == 2
            ? 'fight2'
            : 'fight1';
    final function = contract.function(fun);
    return TransactionService.contractTransaction(
      contract,
      function,
      [tokenId, BigInt.from(count)],
    );
  }

  static Future<List<int>> getFightResults(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await simpleGameContract();
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
