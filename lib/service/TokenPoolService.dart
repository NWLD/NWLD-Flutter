import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenPoolInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenPoolService {
  static Future<TokenPoolInfo> getInfo() async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'tokenPool',
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
        'tokenPool');
    final infoFunction = contract.function('info');
    List result = await client.call(
      contract: contract,
      function: infoFunction,
      params: [],
    );
    return TokenPoolInfo(
        result[0] as BigInt, result[1] as BigInt, result[2] as BigInt);
  }

  static Future<BigInt> estimateBuy(String input) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'tokenPool',
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
        'tokenPool');
    final estimateBuyFunction = contract.function('estimateBuy');
    List result = await client.call(
      contract: contract,
      function: estimateBuyFunction,
      params: [NumberUtil.pow(num: input, exponent: 18)],
    );
    LogUtil.log('estimateBuy', result);
    return result[0] as BigInt;
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