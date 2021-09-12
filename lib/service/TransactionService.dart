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

  static Future<String> send(String to, String amount) async {
    final client = Web3Util().web3Client();
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    EthereumAddress ownAddress = await credentials.extractAddress();

    //手续费价格
    print('getGasPrice');
    EtherAmount gasPrice = await client.getGasPrice();
    print(gasPrice);

    Transaction transaction = Transaction(
      from: ownAddress,
      to: EthereumAddress.fromHex(to),
      gasPrice: gasPrice,
      value: EtherAmount.inWei(
        NumberUtil.pow(num: amount, exponent: 18),
      ),
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
    LogUtil.log('send', hash);
    return hash;
  }

  sendERC20(String erc20Address, String to, String amount) async {
    final client = Web3Util().web3Client();
    final contract =
        await ContractUtil().abiContract('erc20', erc20Address, 'erc20');
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
