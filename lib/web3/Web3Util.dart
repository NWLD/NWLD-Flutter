import 'package:http/http.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:web3dart/web3dart.dart';

class Web3Util {
  static Web3Util _instance;
  Web3Client _web3Client;

  static Web3Util getInstance() {
    if (_instance == null) {
      _instance = Web3Util._internal();
    }
    return _instance;
  }

  factory Web3Util() => getInstance();

  Web3Util._internal() {
    _init();
  }

  void _init() {
    _web3Client = Web3Client(SettingsModel().currentChainRpc(), Client());
  }

  Web3Client web3Client() {
    return _web3Client;
  }
}
