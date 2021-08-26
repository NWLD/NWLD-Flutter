
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/settings_model.dart';

class GameUtils {
  static formatNumber(num value) {
    Locale locale = userLocal();
    return NumberFormat(null, locale.toLanguageTag()).format(value);
  }

  static Locale userLocal() {
    Locale locale = SettingsModel.getInstance().getSelectedLocale();
    if (null == locale) {
      return Locale('en', 'US');
    }
    return locale;
  }

  // 仅用于金币等模糊的加减乘除
  // double 承载不了超过 22 位的十进制数，需要用 Decimal
  static String add(dynamic a, dynamic b) {
    return (Decimal.parse(a.toString()) + Decimal.parse(b.toString()))
        .toStringAsFixed(0);
  }

  static String mul(dynamic a, dynamic b) {
    return (Decimal.parse(a.toString()) * Decimal.parse(b.toString()))
        .toStringAsFixed(0);
  }

  static String div(dynamic a, dynamic b) {
    return (Decimal.parse(a.toString()) / Decimal.parse(b.toString()))
        .toStringAsFixed(0);
  }

  static bool gt(dynamic a, dynamic b) {
    return Decimal.parse(a.toString()) > Decimal.parse(b.toString());
  }

  static bool lt(dynamic a, dynamic b) {
    return Decimal.parse(a.toString()) < Decimal.parse(b.toString());
  }

  static String min(dynamic a, dynamic b) {
    Decimal dA = Decimal.parse(a.toString());
    Decimal dB = Decimal.parse(b.toString());

    return (dA < dB ? dA : dB).toString();
  }

  static String max(dynamic a, dynamic b) {
    Decimal dA = Decimal.parse(a.toString());
    Decimal dB = Decimal.parse(b.toString());

    return (dA > dB ? dA : dB).toString();
  }
}
