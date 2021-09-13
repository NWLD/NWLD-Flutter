import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenShopItem.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenShopService {
  static Future<DeployedContract> tokenShopContract() async {
    final contract = await ContractUtil.abiContract(
        'tokenShop',
        ConfigModel.getInstance().config(ConfigConstants.tokenShop),
        'tokenShop');
    return contract;
  }

  static Future<TokenShopItem> getInfo(int index) async {
    final client = Web3Util().web3Client();
    final contract = await tokenShopContract();
    final infoFunction = contract.function('info');
    String account = AccountModel.getInstance().account;
    if (StringUtils.isEmpty(account)) {
      account = '0x000000000000000000000000000000000000dEaD';
    }
    List result = await client.call(
      contract: contract,
      function: infoFunction,
      params: [EthereumAddress.fromHex(account), BigInt.from(index)],
    );
    LogUtil.log('info', result);
    return TokenShopItem(
      amount: result[0] as BigInt,
      price: result[1] as BigInt,
      qty: (result[2] as BigInt).toInt(),
      soldCount: (result[3] as BigInt).toInt(),
      bought: result[4] as bool,
    );
  }

  static Future<Transaction> buy(BigInt price, int index) async {
    final contract = await tokenShopContract();
    final function = contract.function('buy');
    return TransactionService.contractTransaction(
      contract,
      function,
      [BigInt.from(index)],
      EtherAmount.inWei(price),
    );
  }
}
