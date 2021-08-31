import 'package:http/http.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:web3dart/web3dart.dart';

class Web3Util {
  Web3Client web3Client() {
    return Web3Client(SettingsModel().currentChainRpc(), Client());
  }
}
