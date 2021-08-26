import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oktoast/oktoast.dart' as okToast;

import '../constants/colors.dart';
import '../constants/sizes.dart';

enum ToastType {
  success,
  info,
  warning,
  error,
}

Map<ToastType, Color> ToastColor = {
  ToastType.success: Color(0xFF47B47B),
  ToastType.info: Color(0xFF3E68C1),
  ToastType.warning: Color(0xFFF1A31A),
  ToastType.error: Color(0xFFEC5E5E),
};

Map<ToastType, int> ToastSeconds = {
  ToastType.success: 2,
  ToastType.info: 3,
  ToastType.warning: 4,
  ToastType.error: 5,
};

Map<ToastType, String> ToastIcon = {
  ToastType.success: 'assets/toast/ic_success.png',
  ToastType.info: 'assets/toast/ic_info.png',
  ToastType.warning: 'assets/toast/ic_warning.png',
  ToastType.error: 'assets/toast/ic_error.png',
};

class ToastUtil {
  static showToast(String msg, {type = ToastType.info, int seconds}) {
    if (null != msg && "" != msg.trim()) {
      okToast.showToastWidget(
        ToastUI(
          type: type,
          msg: msg,
        ),
        duration: Duration(
          seconds: seconds ?? ToastSeconds[type],
        ),
        handleTouch: false,
        position: okToast.ToastPosition(
          align: Alignment.topCenter,
          offset: 0,
        ),
        animationBuilder: (
          BuildContext context,
          Widget child,
          AnimationController controller,
          double percent,
        ) {
          return child;
        },
        onDismiss: () {},
        dismissOtherToast: true,
      );
    }
  }
}

class ToastUI extends StatefulWidget {
  final ToastType type;
  final String msg;

  ToastUI({
    Key key,
    @required this.type,
    @required this.msg,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ToastUIState();
}

class _ToastUIState extends State<ToastUI> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<Offset> animation;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    animation =
        Tween(begin: Offset(0.0, -1.0), end: Offset.zero).animate(controller);
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.transparent,
        body: buildWidget(),
      ),
    );
  }

  Widget buildWidget() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SlideTransition(
          position: animation,
          //将要执行动画的子view
          child: Container(
            alignment: Alignment.bottomCenter,
            width: ScreenUtil().screenWidth,
            decoration: BoxDecoration(
              color: ToastColor[widget.type],
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(46.w),
                bottomRight: Radius.circular(46.w),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.61),
                  offset: Offset(0.0, 6.w),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: ToastColor[widget.type],
                  offset: Offset(0.0, 6.w),
                  blurRadius: 0,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: EdgeInsets.only(
                    bottom: 20.w, left: 40.w, right: 40.w, top: 20.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      ToastIcon[widget.type],
                      width: 64.w,
                      height: 64.w,
                    ),
                    Text(
                      widget.msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorConstant.title,
                        fontSize: SizeConstant.h10,
                        fontFamily: 'CarterOne-Regular',
                        height: 1.5,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }
}
