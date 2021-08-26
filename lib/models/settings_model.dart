import 'package:flutter/material.dart';

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
  bool isDarkMode = false;
  bool isSoundOn = false; // 由于未知的原因，频繁播放音效会卡，所以先默认不播放音效
  bool isMusicOn = true;

  // 当 local 和 latest 数据版本不一致的时候，会触发重新登录
  String localDataVersion = '3';
  String latestDataVersion = '3';

  String account;

  init() {
    Map<String, dynamic> cachedData = CacheUtil.getData(CacheKey.settings);

    if (cachedData != null) {
      locale = cachedData['locale'];
      isDarkMode = cachedData['isDarkMode'];
      isSoundOn = cachedData['isSoundOn'];
      isMusicOn = cachedData['isMusicOn'];
      localDataVersion = cachedData['localDataVersion'];
      account = cachedData['account'];
    }

    checkDataVersion();
  }

  saveState() {
    final data = {
      'isMusicOn': isMusicOn,
      'isSoundOn': isSoundOn,
      'isDarkMode': isDarkMode,
      'locale': locale,
      'localDataVersion': localDataVersion,
      'account': account,
    };

    CacheUtil.setData(CacheKey.settings, data);
  }

  onStateChanged() {
    notifyListeners();
    saveState();
  }

  updateIsSoundOn(bool isOn) {
    if (isSoundOn != isOn) {
      isSoundOn = isOn;
      onStateChanged();
    }
  }

  updateIsMusicOn(bool isOn) {
    if (isMusicOn != isOn) {
      isMusicOn = isOn;
      onStateChanged();
    }
  }

  updateTheme(bool isDark) {
    if (isDarkMode != isDark) {
      isDarkMode = isDark;
      onStateChanged();
    }
  }

  updateLocale(String newLocale) {
    if (newLocale != locale) {
      locale = locale;
      onStateChanged();
    }
  }

  updateAccount(String _account) {
    account = _account;
    onStateChanged();
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

  // 数据版本，1.0.0版本缓存的数据格式json解析不对，需要清除数据重新登录
  // 清除用户数据后，启动页会触发重新登录
  void checkDataVersion() async {
    if (latestDataVersion != localDataVersion) {
      localDataVersion = latestDataVersion;
      onStateChanged();
    }
  }
}
