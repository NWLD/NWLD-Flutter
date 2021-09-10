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
}
