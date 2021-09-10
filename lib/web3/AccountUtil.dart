import 'package:kingspro/models/account_model.dart';
import 'package:web3dart/web3dart.dart';

class AccountUtil {
  static Future<Credentials> getPrivateKey(Web3Client web3client) async {
    return await web3client
        .credentialsFromPrivateKey(AccountModel().decodePrivateKey());
  }
}
