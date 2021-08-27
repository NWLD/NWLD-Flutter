import 'dart:convert';

// base64库
import 'dart:convert' as convert;

class StringUtils {
  static String encode(String originalCn) {
    return jsonEncode(Utf8Encoder().convert(originalCn));
  }

  static String decode(String encodeCn) {
    var list = <int>[];
    jsonDecode(encodeCn).forEach(list.add);
    String value = Utf8Decoder().convert(list);
    return value;
  }

  static String double2String(String d) {
    if (d.contains(".")) {
      d = d.substring(0, d.indexOf("."));
    }
    return d;
  }

  static String trimZero(String amount) {
    if (null != amount && amount.indexOf(".") > 0) {
      // 去掉多余的0
      amount = amount.replaceAll(new RegExp(r"0+?$"), "");
      // 如最后一位是.则去掉
      amount = amount.replaceAll(new RegExp(r"[.]$"), "");
    }
    return amount;
  }

  static String trimZero4Local(String amount, String local) {
    if (null == local || "" == local || "id" != local) {
      return trimZero(amount);
    }
    if (null != amount && amount.indexOf(",") > 0) {
      // 去掉多余的0
      amount = amount.replaceAll(new RegExp(r"0+?$"), "");
      // 如最后一位是.则去掉
      amount = amount.replaceAll(new RegExp(r"[,]$"), "");
    }
    return amount;
  }

  /*
  * Base64加密
  */
  static String base64Encode(String data) {
    var content = convert.utf8.encode(data);
    var digest = convert.base64Encode(content);
    return digest;
  }

  /*
  * Base64解密
  */
  static String base64Decode(String data) {
    List<int> bytes = convert.base64Decode(data);
    // 网上找的很多都是String.fromCharCodes，这个中文会乱码
    //String txt1 = String.fromCharCodes(bytes);
    String result = convert.utf8.decode(bytes);
    return result;
  }

  static int str2Int(String str) {
    if (null == str || "" == str.trim()) {
      return 0;
    }
    try {
      int value = int.parse(str);
      return value;
    } catch (e) {
      return 0;
    }
  }

  static double str2double(String str) {
    if (null == str || "" == str.trim()) {
      return 0;
    }
    try {
      double value = double.parse(str);
      return value;
    } catch (e) {
      return 0;
    }
  }

  static bool isEmpty(String str) {
    return null == str || "" == str.trim();
  }

  static String simpleAccount(String account) {
    if (isEmpty(account)) {
      return "";
    }
    if (14 > account.length) {
      return account;
    }
    return account.substring(0, 6) +
        "****" +
        account.substring(account.length - 4);
  }
}
