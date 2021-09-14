import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetUpdateInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetUpgrade1Service {
  static Future<DeployedContract> petUpgrade1Contract() async {
    final contract = await ContractUtil.abiContract(
        'petUpgrade1',
        ConfigModel.getInstance().config(ConfigConstants.petUpgrade1),
        'petUpgrade1');
    return contract;
  }

  static Future<PetUpdateInfo> getInfo(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await petUpgrade1Contract();
    final priceFunction = contract.function('price');
    List priceResult = await client.call(
      contract: contract,
      function: priceFunction,
      params: [],
    );
    final rateFunction = contract.function('getRate');
    List rateResult = await client.call(
      contract: contract,
      function: rateFunction,
      params: [tokenId],
    );
    return PetUpdateInfo(
      priceResult[0] as BigInt,
      NumberUtil.decimalNumString(
              num: rateResult[0].toString(), decimals: '2', fractionDigits: 2) +
          '%',
    );
  }

  static Future<Transaction> upgrade(BigInt tokenId) async {
    final contract = await petUpgrade1Contract();
    final function = contract.function('upgrade');
    return TransactionService.contractTransaction(
      contract,
      function,
      [tokenId],
    );
  }
}
