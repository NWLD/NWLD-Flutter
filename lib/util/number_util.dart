import 'package:decimal/decimal.dart';

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
}
