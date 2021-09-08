import 'package:flutter/material.dart';
import 'package:kingspro/entity/chain.dart';
import 'package:kingspro/util/aes_util.dart';
import 'package:kingspro/util/common_utils.dart';
import 'package:kingspro/util/string_util.dart';

import '../util/cache_util.dart';

class SettingsModel extends ChangeNotifier {
  static SettingsModel _instance;

  static SettingsModel getInstance() {
    if (_instance == null) {
      _instance = SettingsModel.internal();
    }

    return _instance;
  }

  factory SettingsModel() => getInstance();

  SettingsModel.internal() {
    init();
  }

  String locale;
  String chainSymbol;
  String chainRpc;

  String pwd;

  init() {
    Map<String, dynamic> cachedData = CacheUtil.getData(CacheKey.settings);
    if (cachedData != null) {
      locale = cachedData['locale'];
      chainSymbol = cachedData['chainSymbol'];
      chainRpc = cachedData['chainRpc'];
      pwd = cachedData['pwd'];
    }
  }

  saveState() {
    final data = {
      'locale': locale,
      'chainSymbol': chainSymbol,
      'chainRpc': chainRpc,
      'pwd': pwd,
    };

    CacheUtil.setData(CacheKey.settings, data);
  }

  onStateChanged() {
    notifyListeners();
    saveState();
  }

  updateLocale(String newLocale) {
    if (newLocale != locale) {
      locale = locale;
      onStateChanged();
    }
  }

  updateChain(String _chain) {
    chainSymbol = _chain;
    onStateChanged();
  }

  Chain currentChain() {
    Chain chain = ChainConstant.symbolChain(chainSymbol);
    if (null != chain) {
      return chain;
    }
    return ChainConstant.symbolChain(ChainConstant.HT);
  }

  String currentChainRpc() {
    if (StringUtils.isEmpty(chainRpc)) {
      return currentChain().rpcList[0];
    }
    return chainRpc;
  }

  String getPwd() {
    String key = "ADG6fkvJM257PSVY";
    if (StringUtils.isEmpty(pwd)) {
      pwd = AESUtil.encodeBase64(CommonUtils.getRandomPwd(), key, key);
      saveState();
    }
    return AESUtil.decodeBase64(pwd, key, key);
  }

  Locale getSelectedLocale() {
    if (locale == null) return null;
    var t = locale.split('_');
    return Locale(t[0], t[1]);
  }

  supportedLocales() {
    return [
      Locale('en', 'US'),
      Locale('zh', 'CN'),
    ];
  }
}
