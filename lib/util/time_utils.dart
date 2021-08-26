import 'package:intl/intl.dart';

class TimeUtil {
  static String parseUTCTimeToLocalTime(String utctime) {
    if (utctime != null) {
      // return DateTime.parse(utctime).toLocal().toString();
      DateTime localtime = DateTime.parse(utctime).toLocal();
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(localtime);
    } else {
      return "";
    }
  }

  /**
   * return String '08:59:01'
   */
  static String formatDuration(int seconds) {
    seconds = seconds ?? 0;
    return Duration(seconds: seconds).toString().split('.').first.padLeft(8, "0");
  }
}
