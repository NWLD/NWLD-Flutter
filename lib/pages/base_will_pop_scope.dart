import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BaseWillPopScope extends StatefulWidget {
  final Widget child;
  final bool doubleClickExit; //双击退出

  BaseWillPopScope({
    Key key,
    this.child,
    this.doubleClickExit = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BaseWillPopScope();
  }
}

class _BaseWillPopScope extends State<BaseWillPopScope> {
  DateTime _lastPressed;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: widget.child,
      onWillPop: () async {
        if (!widget.doubleClickExit) {
          return false;
        }
        if (_lastPressed == null ||
            DateTime.now().difference(_lastPressed) > Duration(seconds: 1)) {
          //两次点击间隔超过1秒则重新计时
          _lastPressed = DateTime.now();
          return false;
        }
        // 退出app
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return true;
      },
    );
  }
}
