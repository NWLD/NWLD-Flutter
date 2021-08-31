import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../routes/routes.dart';
import '../widgets/scale_widget.dart';
import 'base_will_pop_scope.dart';

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SplashPageState();
  }
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      duration: Duration(
        milliseconds: 3000,
      ),
      vsync: this,
    );
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        toIndex();
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
      } else if (status == AnimationStatus.forward) {
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
      }
    });
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toIndex() async {
    Navigator.pushReplacementNamed(context, RouteMap.home);
  }

  @override
  Widget build(BuildContext context) {
    return BaseWillPopScope(
      doubleClickExit: false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: ColorConstant.appBackground,
        alignment: AlignmentDirectional.center,
        child: Scale(
          lowerBound: 0.9,
          value: 0.9,
          repeat: true,
          start: true,
          upperBound: 1.1,
          reverseDuration: 500,
          duration: 500,
          child: Image.asset(
            'assets/splash_icon.png',
            width: 384.w,
            height: 384.w,
          ),
        ),
      ),
    );
  }
}
