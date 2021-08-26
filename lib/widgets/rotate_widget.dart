import 'package:flutter/material.dart';

///旋转
class Rotate extends StatefulWidget {
  final Widget child;
  final int milliseconds;

  Rotate({
    Key key,
    @required this.child,
    this.milliseconds = 3000,
  }) : super(key: key);

  @override
  _RotateState createState() {
    return _RotateState();
  }
}

class _RotateState extends State<Rotate> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    //duration 动画的时长，这里设置的 seconds: 2 为2秒，当然也可以设置毫秒 milliseconds：2000.
    controller = AnimationController(
      value: 0,
      duration: Duration(
        milliseconds: widget.milliseconds,
      ),
      lowerBound: 0.0,
      upperBound: 1.0,
      vsync: this,
    );
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
      } else if (status == AnimationStatus.forward) {
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
      }
    });
    controller.repeat();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      child: widget.child,
      turns: controller,
    );
  }
}
