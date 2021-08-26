import 'package:flutter/material.dart';

import 'base_localizations.dart';

class BaseLocalizationsDelegate extends LocalizationsDelegate<BaseLocalizations> {
  BaseLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // return ['en', 'zh-cn'].contains(locale.languageCode);
    return true;
  }

  @override
  Future<BaseLocalizations> load(Locale locale) async {
    BaseLocalizations localizations = new BaseLocalizations(locale);

    await localizations.load();

    print('Load ${locale.languageCode}');

    return localizations;
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<BaseLocalizations> old) {
    return false;
  }
}
