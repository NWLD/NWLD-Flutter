import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetShopInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetShopService {
  static Future<DeployedContract> petShopContract() async {
    final contract = await ContractUtil.abiContract('petShop',
        ConfigModel.getInstance().config(ConfigConstants.petShop), 'petShop');
    return contract;
  }

  static Future<PetShopInfo> getInfo() async {
    final client = Web3Util().web3Client();
    final contract = await petShopContract();
    final infoFunction = contract.function('shopInfo');
    List result = await client.call(
      contract: contract,
      function: infoFunction,
      params: [],
    );
    LogUtil.log('info', result);
    return PetShopInfo(
      nowTime: (result[0] as BigInt).toInt(),
      title: result[1].toString(),
      des: result[2].toString(),
      startTime: (result[3] as BigInt).toInt(),
      price: result[4] as BigInt,
      qty: (result[5] as BigInt).toInt(),
      soldCount: (result[6] as BigInt).toInt(),
    );
  }

  static Future<Transaction> buy(int num) async {
    final contract = await petShopContract();
    final function = contract.function('buy');
    return TransactionService.contractTransaction(
      contract,
      function,
      [BigInt.from(num)],
    );
  }
}
