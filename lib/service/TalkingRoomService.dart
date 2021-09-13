import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TalkingData.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class TalkingRoomService {
  static Future<DeployedContract> talkingRoomContract() async {
    final contract = await ContractUtil.abiContract(
        'talkingRoom',
        ConfigModel.getInstance().config(ConfigConstants.talkingRoom),
        'talkingRoom');
    return contract;
  }

  static Future<TalkingDataList> getTalkingDataList(BigInt lastIndex) async {
    final client = Web3Util().web3Client();
    final contract = await talkingRoomContract();
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

  static Future<Transaction> sendMsg(String msg) async {
    final contract = await talkingRoomContract();
    final function = contract.function('sendMsg');
    return TransactionService.contractTransaction(
      contract,
      function,
      [msg],
    );
  }
}
