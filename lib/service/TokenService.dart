import 'package:kingspro/constants/config.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenService {
  static Future<DeployedContract> gameTokenContract() async {
    final contract = await ContractUtil.erc20Contract(
        ConfigModel.getInstance().config(ConfigConstants.gameToken),
        ConfigModel.getInstance().config(ConfigConstants.gameTokenSymbol));
    return contract;
  }

  static Future<BigInt> allowance(String address) async {
    LogUtil.log('allowance', "start");
    final client = Web3Util().web3Client();
    final contract = await gameTokenContract();
    final function = contract.function('allowance');
    EthereumAddress ownAddress =
        EthereumAddress.fromHex(AccountModel.getInstance().account);

    List result = await client.call(
      contract: contract,
      function: function,
      params: [ownAddress, EthereumAddress.fromHex(address)],
    );
    return result[0] as BigInt;
  }

  static Future<Transaction> approve(String address, BigInt amount) async {
    final contract = await gameTokenContract();
    final function = contract.function('approve');
    return TransactionService.contractTransaction(
      contract,
      function,
      [EthereumAddress.fromHex(address), amount],
    );
  }
}
