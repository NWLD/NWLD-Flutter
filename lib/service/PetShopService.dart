import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetShopInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
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

  static Future<String> buy(int num) async {
    final client = Web3Util().web3Client();
    final contract = await petShopContract();
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
      gasPrice: gasPrice,
      parameters: [BigInt.from(num)],
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
