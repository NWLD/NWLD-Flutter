import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CacheUtil {
  static const cachePrefix = 'v1';

  // get 同步， set 异步
  static SharedPreferences sharedPreferences;

  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static pre(key) {
    return [cachePrefix, key].join('_');
  }

  static set(String key, String value) {
    return sharedPreferences.setString(pre(key), value);
  }

  static String get(String key) {
    return sharedPreferences.getString(pre(key));
  }

  static getData(String key) {
    String jsonString = get(key);

    if (null == jsonString || "" == jsonString.trim()) {
      return null;
    }
    try {
      return json.decode(jsonString);
    } catch (e) {
      print('Error: Cache.getData: $e');
      return null;
    }
  }

  // 适宜用来放 json、bool 等类型
  static setData(String key, dynamic data) {
    if (null == data) {
      return;
    }
    try {
      String jsonString = json.encode(data);
      set(key, jsonString);
    } catch (e) {
      print('Error: Cache.setData: $e');
    }
  }
}

class CacheKey {
  static const String settings = 'settings';
  static const String userModel = 'userModel';
  static const String messageModel = 'messageModel';
  static const String gameConfig = 'gameConfig';
  static const String accessToken = 'accessToken';
  static const String gameModel = 'gameModel';

  static const String isTest = 'isTest';
  static const String isDebug = 'isDebug';

  static const String doNotRemindBindReferrer = 'doNotRemindBindReferrer';
  static const String lastTimeShowBindReferrerDialog = 'lastTimeShowBindReferrerDialog';
}
