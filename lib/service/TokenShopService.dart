import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenShopItem.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TokenShopService {
  static Future<TokenShopItem> getInfo(int index) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'tokenShop',
        ConfigModel.getInstance().config(ConfigConstants.tokenShop),
        'tokenShop');
    final infoFunction = contract.function('info');
    List result = await client.call(
      contract: contract,
      function: infoFunction,
      params: [
        EthereumAddress.fromHex(AccountModel.getInstance().account),
        BigInt.from(index)
      ],
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

  static Future<String> buy(BigInt price, int index) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'tokenShop',
        ConfigModel.getInstance().config(ConfigConstants.tokenShop),
        'tokenShop');
    final buyFunction = contract.function('buy');
    Credentials credentials = await AccountUtil.getPrivateKey(client);
    EthereumAddress ownAddress = await credentials.extractAddress();

    //手续费价格
    print('getGasPrice');
    EtherAmount gasPrice = await client.getGasPrice();
    print(gasPrice);

    Transaction transaction = Transaction.callContract(
      contract: contract,
      function: buyFunction,
      from: ownAddress,
      value: EtherAmount.inWei(price),
      gasPrice: gasPrice,
      parameters: [BigInt.from(index)],
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

    String buyHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('buy', buyHash);
    return buyHash;
  }
}
