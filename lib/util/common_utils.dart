import 'dart:convert';
import 'dart:math';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

// import 'cache.dart';

class CommonUtils {
  static sleep(int ms) {
    return Future.delayed(Duration(milliseconds: ms));
  }

  static List<String> getSortedMapKeys(Map<String, dynamic> map) {
    List<String> keys = map.keys.toList();
    // key排序
    keys.sort((key1, key2) {
      List<int> units1 = key1.codeUnits;
      List<int> units2 = key2.codeUnits;

      for (int i = 0; i < units1.length; i++) {
        if (units2.length <= i) {
          return 1;
        }
        if (units1[i] > units2[i]) {
          return 1;
        } else if (units1[i] < units2[i]) {
          return -1;
        }
      }
      return 0;
    });
    return keys;
  }

  static String generateMD5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    // 这里其实就是 digest.toString()
    return hex.encode(digest.bytes);
  }

  static String getRandomPwd() {
    String chars1 = "ADGJMPSVY";
    String chars2 = "13579";
    String chars3 = "fkv";
    String chars4 = "257";

    StringBuffer stringBuffer = StringBuffer();
    Random random = new Random();
    int randomInt = random.nextInt(10000);
    int randomIndex = randomInt % chars1.length;

    stringBuffer.write(chars1.substring(randomIndex, randomIndex + 1));
    randomInt = random.nextInt(500);
    randomIndex = randomInt % chars2.length;

    stringBuffer.write(chars2.substring(randomIndex, randomIndex + 1));
    randomInt = random.nextInt(300);
    randomIndex = randomInt % chars3.length;

    stringBuffer.write(chars3.substring(randomIndex, randomIndex + 1));
    randomInt = random.nextInt(100);
    randomIndex = randomInt % chars4.length;

    stringBuffer.write(chars4.substring(randomIndex, randomIndex + 1));
    return stringBuffer.toString();
  }
}
