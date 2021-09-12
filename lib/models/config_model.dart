import 'package:flutter/material.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/service/ConfigService.dart';

class ConfigModel extends ChangeNotifier {
  static ConfigModel _instance;
  bool hasConfig = false;

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
    Map<String, String> configs = await ConfigService.getConfigs();
    updateConfig(configs);
    AccountModel.getInstance().getBalance();
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
