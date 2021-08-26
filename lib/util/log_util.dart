class LogUtil {
  static void log(String tag, Object object) {
    if (tag == null) {
      tag = "tag";
    }

    String msg = "null";

    if (object != null) {
      msg = object.toString();
    }

    int len = msg.length;
    int limit = 1000;
    int start = 0;
    int end = limit;
    bool empty = false;

    for (var index = 0; index < len; index++) {
      start = index * limit;
      end = start + limit;

      if (end >= len) {
        end = len;
        empty = true;
      }

      String value = msg.substring(start, end);

      print("$tag=$value");

      if (empty) {
        break;
      }
    }
  }
}
