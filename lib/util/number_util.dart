import 'package:decimal/decimal.dart';

import 'string_util.dart';

class NumberUtil {
  static Decimal decimal({String num}) {
    final d = Decimal.tryParse;
    Decimal decimal;
    if (isTrimEmpty(num)) {
      decimal = d("0");
    } else {
      decimal = d(num);
    }
    return decimal;
  }

  static Decimal divide({String total, String divideNum}) {
    Decimal totalDecimal = decimal(num: total);
    Decimal divideDecimal = decimal(num: divideNum);
    return totalDecimal / divideDecimal;
  }

  static String divideStr({
    String total,
    String divideNum,
    int decimals = 8,
    bool trimZero = true,
  }) {
    Decimal divideDecimal = divide(total: total, divideNum: divideNum);
    String numStr = divideDecimal.toStringAsFixed(decimals);
    if (trimZero) {
      numStr = trimTailZero(numStr);
    }
    return numStr;
  }

  static bool isTrimEmpty(String string) {
    return null == string || '' == string.trim();
  }

  static String trimTailZero(String amount) {
    if (null != amount && amount.indexOf(".") > 0) {
      // 去掉多余的0
      amount = amount.replaceAll(new RegExp(r"0+?$"), "");
      // 如最后一位是.则去掉
      amount = amount.replaceAll(new RegExp(r"[.]$"), "");
    }
    return amount;
  }

  static String toIntString(String str) {
    return decimal(num: str).toStringAsFixed(0);
  }

  static Decimal decimalNum({String num, String decimals = '18'}) {
    final d = Decimal.tryParse;
    Decimal decimal;
    if (StringUtils.isEmpty(num)) {
      decimal = d("0");
    } else if (StringUtils.isEmpty(decimals)) {
      decimal = d(num);
    } else {
      decimal = d(num) / (d('10').pow(StringUtils.str2Int(decimals)));
    }
    return decimal;
  }

  static String decimalNumString({
    String num,
    String decimals = '18',
    int fractionDigits = 4,
    bool trimZero = true,
  }) {
    Decimal decimal = decimalNum(num: num, decimals: decimals);
    String numString;
    //精度处理
    if (null == fractionDigits) {
      numString = decimal.toString();
    } else {
      numString = decimal.toStringAsFixed(fractionDigits);
    }
    if (trimZero) {
      return StringUtils.trimZero(numString);
    }
    return numString;
  }
}
