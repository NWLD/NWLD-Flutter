import 'package:encrypt/encrypt.dart';

class AESUtil {
  static Encrypted encode(String plainText, String aesKey, String ivKey) {
    final key = Key.fromUtf8(aesKey); //加密key
    final iv = IV.fromUtf8(ivKey); //偏移量
    //设置cbc模式
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted;
  }

  static String encodeBase16(String plainText, String aesKey, String ivKey) {
    return encode(plainText, aesKey, ivKey).base16;
  }

  static String encodeBase64(String plainText, String aesKey, String ivKey) {
    return encode(plainText, aesKey, ivKey).base64;
  }

  static String decodeBase64(String aesBase64, String aesKey, String ivKey) {
    final key = Key.fromUtf8(aesKey); //加密key
    final iv = IV.fromUtf8(ivKey); //偏移量
    //设置cbc模式
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    String decrpted = encrypter.decrypt64(aesBase64, iv: iv);
    return decrpted;
  }
}
