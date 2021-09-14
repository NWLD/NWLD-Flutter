import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetUpdateInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetUpgrade2Service {
  static Future<DeployedContract> petUpgrade2Contract() async {
    final contract = await ContractUtil.abiContract(
        'petUpgrade2',
        ConfigModel.getInstance().config(ConfigConstants.petUpgrade2),
        'petUpgrade2');
    return contract;
  }

  static Future<PetUpdateInfo> getInfo(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await petUpgrade2Contract();
    final priceFunction = contract.function('price');
    List priceResult = await client.call(
      contract: contract,
      function: priceFunction,
      params: [],
    );
    return PetUpdateInfo(
      priceResult[0] as BigInt,
      '100%',
    );
  }

  static Future<Transaction> upgrade(BigInt tokenId, BigInt costId) async {
    final contract = await petUpgrade2Contract();
    final function = contract.function('upgrade');
    return TransactionService.contractTransaction(
      contract,
      function,
      [tokenId, costId],
    );
  }
}
