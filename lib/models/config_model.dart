import 'package:flutter/material.dart';
import 'package:kingspro/service/ConfigService.dart';

class ConfigModel extends ChangeNotifier {
  static ConfigModel _instance;

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

  _init() async {
    Map<String, String> configs = await ConfigService.getConfigs();
    updateConfig(configs);
  }

  updateConfig(Map<String, String> map) {
    _configMap = map ?? {};
    notifyListeners();
  }

  String config(String key) {
    return _configMap[key] ?? "";
  }
}
