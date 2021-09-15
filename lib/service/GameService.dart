import 'package:kingspro/entity/FightPet.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class GameService {
  String abiFileName;
  String address;

  GameService(this.abiFileName, this.address);

  Future<DeployedContract> gameContract() async {
    final contract =
        await ContractUtil.abiContract(abiFileName, address, abiFileName);
    return contract;
  }

  Future<FightReward> getFightReward() async {
    final client = Web3Util().web3Client();
    final contract = await gameContract();
    final function = contract.function('getFightReward');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [],
    );
    return FightReward(result[0] as BigInt, result[1] as BigInt);
  }

  Future<List<FightPet>> getFightPets() async {
    final client = Web3Util().web3Client();
    final contract = await gameContract();
    final function = contract.function('getFightPets');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [
        EthereumAddress.fromHex(AccountModel.getInstance().account),
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

  Future<Transaction> fight(
    BigInt tokenId,
    int count,
  ) async {
    final contract = await gameContract();
    final function = contract.function('fight');
    return TransactionService.contractTransaction(
      contract,
      function,
      [tokenId, BigInt.from(count)],
    );
  }

  Future<List<int>> getFightResults(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await gameContract();
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
