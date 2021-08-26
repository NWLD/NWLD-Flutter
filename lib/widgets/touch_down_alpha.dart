import 'package:flutter/material.dart';

class TouchDownAlpha extends StatefulWidget {
  final Widget child;

  TouchDownAlpha({
    Key key,
    @required this.child,
  }) : super(key: key);

  @override
  _TouchDownAlphaState createState() => _TouchDownAlphaState();
}

class _TouchDownAlphaState extends State<TouchDownAlpha> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;
  bool isPointerUp = false;
  bool isDismissed = false;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    final duration = Duration(milliseconds: 50);
    controller = AnimationController(
      value: 1,
      duration: duration,
      reverseDuration: duration,
      lowerBound: 0.4,
      upperBound: 1,
      vsync: this,
    );
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        isDismissed = true;
        if (isPointerUp) {
          controller.forward();
        }
      } else if (status == AnimationStatus.forward) {
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        isPointerUp = false;
        isDismissed = false;
        controller.reverse();
      },
      onPointerUp: (event) {
        isPointerUp = true;
        if (isDismissed) {
          controller.forward();
        }
      },
      onPointerCancel: (event) {
        controller.forward();
      },
      child: FadeTransition(
        opacity: controller,
        child: widget.child,
      ),
    );
  }
}
