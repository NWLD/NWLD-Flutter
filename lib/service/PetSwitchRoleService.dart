import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetUpdateInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetSwitchRoleService {
  static Future<DeployedContract> petSwitchRoleContract() async {
    final contract = await ContractUtil.abiContract(
        'petSwitchRole',
        ConfigModel.getInstance().config(ConfigConstants.petSwitchRole),
        'petSwitchRole');
    return contract;
  }

  static Future<PetUpdateInfo> getInfo(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await petSwitchRoleContract();
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

  static Future<Transaction> switchRole(BigInt tokenId, int who) async {
    final contract = await petSwitchRoleContract();
    final function = contract.function('switchRole');
    return TransactionService.contractTransaction(
      contract,
      function,
      [tokenId, BigInt.from(who)],
    );
  }
}
