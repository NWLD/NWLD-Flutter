import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenService {
  static Future<BigInt> allowance(String address) async {
    LogUtil.log('allowance', "start");
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().gameTokenContract();
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

  static Future<String> approve(String address, BigInt amount) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().gameTokenContract();
    final function = contract.function('approve');
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
      parameters: [EthereumAddress.fromHex(address), amount],
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

    String approveHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('approve', approveHash);
    return approveHash;
  }
}
