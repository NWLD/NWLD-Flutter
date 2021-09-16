import 'package:flutter/material.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/service/ConfigService.dart';

class ConfigModel extends ChangeNotifier {
  static ConfigModel _instance;
  bool hasConfig = false;
  BigInt gasPrice;

  static ConfigModel getInstance() {
    if (_instance == null) {
      _instance = ConfigModel._internal();
    }
    return _instance;
  }

  factory ConfigModel() => getInstance();

  ConfigModel._internal() {
    _init();
  }

  Map<String, String> _configMap = {};

  _init() {
    refresh();
  }

  void refresh() async {
    getGasPrice();
    Map<String, String> configs = await ConfigService.getConfigs();
    updateConfig(configs);
    AccountModel.getInstance().getBalance();
  }

  getGasPrice() async {
    BigInt price = await ConfigService.getIntConfig(ConfigConstants.gasPrice);
    if (BigInt.from(0) != price) {
      gasPrice = price;
    }
  }

  updateConfig(Map<String, String> map) {
    _configMap = map ?? {};
    hasConfig = true;
    notifyListeners();
  }

  String config(String key) {
    return _configMap[key] ?? "";
  }
}
