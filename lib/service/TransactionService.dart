import 'package:kingspro/entity/GasInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TransactionService {
  static Future<int> getStatus(String hash) async {
    final client = Web3Util().web3Client();
    TransactionReceipt transactionReceipt =
        await client.getTransactionReceipt(hash);
    if (null == transactionReceipt) {
      print('pending');
      return 0;
    }
    if (transactionReceipt.status) {
      print('success');
      return 1;
    }
    print('failed');
    return 2;
  }

  static Transaction valueTransaction(String to, String amount) {
    return Transaction(
      from: EthereumAddress.fromHex(AccountModel.getInstance().account),
      to: EthereumAddress.fromHex(to),
      value: EtherAmount.inWei(
        NumberUtil.pow(num: amount, exponent: 18),
      ),
    );
  }

  static Future<String> send(Transaction transaction) async {
    final client = Web3Util().web3Client();
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    String hash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('send', hash);
    return hash;
  }

  static Future<GasInfo> estimateGas(Transaction transaction) async {
    final client = Web3Util().web3Client();
    //手续费价格
    // EtherAmount gasPrice = await client.getGasPrice();
    EtherAmount gasPrice = EtherAmount.inWei(
      ConfigModel.getInstance().gasPrice ??
          SettingsModel().currentChain().gasPrice,
    );
    transaction = transaction.copyWith(gasPrice: gasPrice);

    BigInt maxGas = await client.estimateGas(
      sender: transaction.from,
      to: transaction.to,
      data: transaction.data,
      value: transaction.value,
      gasPrice: transaction.gasPrice,
    );
    //1.1倍估算的gas，避免交易失败
    maxGas = maxGas * BigInt.from(110) ~/ BigInt.from(100);
    transaction = transaction.copyWith(maxGas: maxGas.toInt());
    return GasInfo(transaction);
  }

  static Transaction contractTransaction(DeployedContract contract,
      ContractFunction function, List<dynamic> parameters,
      [EtherAmount value]) {
    return Transaction.callContract(
      from: EthereumAddress.fromHex(AccountModel.getInstance().account),
      contract: contract,
      function: function,
      parameters: parameters,
      value: value,
    );
  }

  sendERC20(String erc20Address, String to, String amount) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil.erc20Contract(erc20Address, 'erc20');
    final function = contract.function('transfer');
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    EthereumAddress ownAddress = await credentials.extractAddress();
    //手续费价格
    print('getGasPrice');
    EtherAmount gasPrice = await client.getGasPrice();
    print(gasPrice);

    Transaction transaction = Transaction.callContract(
      contract: contract,
      function: function,
      from: ownAddress,
      gasPrice: gasPrice,
      parameters: [
        EthereumAddress.fromHex(to),
        NumberUtil.pow(
          num: amount,
          exponent: 18,
        )
      ],
    );

    BigInt maxGas = await client.estimateGas(
      sender: transaction.from,
      to: transaction.to,
      data: transaction.data,
      value: transaction.value,
      gasPrice: transaction.gasPrice,
    );
    //1.2倍估算的gas，避免交易失败
    maxGas = maxGas * BigInt.from(120) ~/ BigInt.from(100);
    print(maxGas);

    transaction = transaction.copyWith(maxGas: maxGas.toInt());

    String hash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('sendERC20', hash);
    return hash;
  }
}
