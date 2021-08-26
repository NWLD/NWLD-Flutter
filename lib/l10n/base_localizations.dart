import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseLocalizations {
  Locale locale;

  BaseLocalizations(this.locale);

  static BaseLocalizations of(BuildContext context) {
    return Localizations.of<BaseLocalizations>(context, BaseLocalizations);
  }

  Map<String, String> _sentences;

  Future<bool> load() async {
    String data = await rootBundle.loadString('assets/i18n/${locale.languageCode}.json');
    // String data = await rootBundle.loadString('assets/i18n/en.json');
    final _result = json.decode(data);

    this._sentences = new Map();

    _result.forEach((key, value) {
      this._sentences[key] = value.toString();
    });

    print('language ${locale.languageCode} is loaded');

    return true;
  }

  String trans(String key, [Map<String, dynamic> params]) {
    // load(); // 热加载翻译文件
    if (null == _sentences) {
      print("_sentences is null");
      return key;
    }

    String result = this._sentences[key];

    if (result == null && key.length >= 20) {
      result = this._sentences[key.substring(0, 20)]; // 对于超长文本，取前 20 个字符
    }

    if (result == null) {
      print('"$key" 未翻译');
      result = key;
    }

    if (params != null) {
      params.keys.forEach((element) {
        result = result.replaceAll('{$element}', params[element].toString() ?? '');
      });
    }

    return result;
  }

  static String $t(String key, context, [Map<String, dynamic> params]) {
    if (null == BaseLocalizations.of(context)) {
      print("BaseLocalizations is null");
      return key;
    }
    return BaseLocalizations.of(context).trans(key, params);
  }
}

mixin BaseLocalizationsStateMixin<T extends StatefulWidget> on State<T> {
  $t(String key, [Map<String, dynamic> params]) {
    return BaseLocalizations.$t(key, context, params);
  }
}

typedef $tFunction = String Function(String key, [Map<String, dynamic> params]);

$tFunction create$t(BuildContext context) {
  return (String key, [params]) => BaseLocalizations.$t(key, context, params);
}
