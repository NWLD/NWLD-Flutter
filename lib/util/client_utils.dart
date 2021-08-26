import 'dart:async';
import 'dart:io';

import 'package:package_info/package_info.dart';

import 'cache_util.dart';

class ClientUtils {
  static String version;
  static bool isVpnOpen;

  // release/debug
  static bool get isRelease => bool.fromEnvironment("dart.vm.product") ?? true;

  // 数据环境，正式 or 测试
  static bool get isTest => CacheUtil.getData(CacheKey.isTest) ?? false;

  // 用于调试部分功能
  static bool get isDebug => CacheUtil.getData(CacheKey.isDebug) ?? false;

  static Future<String> getAppVersion() async {
    if (version == null) {
      version = '1.0.0';
      try {
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        version = packageInfo.version;
      } catch (e) {
        print('todo: 需要上报');
        print(e);
      }
    }
    return version;
  }

  // 判断 VPN 状态
  static Future<bool> getVpnStatus() async {
    if (isVpnOpen == null) {
      isVpnOpen = false;
      try {
        List<NetworkInterface> interfaces = await NetworkInterface.list(
          includeLoopback: false,
          type: InternetAddressType.any,
        );

        if (interfaces.isNotEmpty) {
          isVpnOpen = interfaces.any((interface) =>
              interface.name.contains("tun") ||
              interface.name.contains("ppp") ||
              interface.name.contains("pptp") ||
              interface.name.contains("ipsec") ||
              interface.name.contains("tap"));
        }
      } catch (e) {
        print('todo: 上报');
        print(e);
      }
    }
    return isVpnOpen;
  }
}
