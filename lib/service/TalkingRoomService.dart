import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TalkingData.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/AccountUtil.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TalkingRoomService {
  static Future<TalkingDataList> getTalkingDataList(BigInt lastIndex) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'talkingRoom',
        ConfigModel.getInstance().config(ConfigConstants.talkingRoom),
        'talkingRoom');
    final function = contract.function('getTalkingData');
    List result = await client.call(
      contract: contract,
      function: function,
      params: [lastIndex],
    );
    List msgList = result[0] as List;
    List addressList = result[1] as List;
    List timeList = result[2] as List;
    BigInt newIndex = result[3] as BigInt;
    List nickList = result[4] as List;
    int len = msgList.length;

    List<TalkingData> list = [];
    for (int index = 0; index < len; index++) {
      list.add(
        TalkingData(
          address: addressList[index].toString(),
          msg: msgList[index].toString(),
          nick: nickList[index].toString(),
          time: (timeList[index] as BigInt).toInt(),
        ),
      );
    }
    return TalkingDataList(list: list, lastIndex: newIndex);
  }

  static Future<String> sendMsg(String msg) async {
    final client = Web3Util().web3Client();
    final contract = await ContractUtil().abiContract(
        'talkingRoom',
        ConfigModel.getInstance().config(ConfigConstants.talkingRoom),
        'talkingRoom');
    final function = contract.function('sendMsg');
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
      parameters: [msg],
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

    String fightHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: SettingsModel().currentChain().chainId,
    );
    LogUtil.log('sendMsgHash', fightHash);
    return fightHash;
  }
}
