import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenPoolInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenPoolService {
  static Future<DeployedContract> tokenPoolContract() async {
    final contract = await ContractUtil.abiContract(
        'tokenPool',
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
        'tokenPool');
    return contract;
  }

  static Future<TokenPoolInfo> getInfo() async {
    final client = Web3Util().web3Client();
    final contract = await tokenPoolContract();
    final infoFunction = contract.function('info');
    List result = await client.call(
      contract: contract,
      function: infoFunction,
      params: [],
    );
    return TokenPoolInfo(result[0] as BigInt, result[1] as BigInt,
        result[2] as BigInt, result[3] as BigInt);
  }

  static Future<Transaction> buy(String input) async {
    final contract = await tokenPoolContract();
    final function = contract.function('buy');
    return TransactionService.contractTransaction(
      contract,
      function,
      [],
      EtherAmount.inWei(
        NumberUtil.pow(num: input, exponent: 18),
      ),
    );
  }

  static Future<Transaction> sell(String input) async {
    final contract = await tokenPoolContract();
    final function = contract.function('sell');
    return TransactionService.contractTransaction(
      contract,
      function,
      [NumberUtil.pow(num: input, exponent: 18)],
    );
  }
}
