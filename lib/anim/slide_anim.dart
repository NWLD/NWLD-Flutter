import 'package:flutter/material.dart';

class SlideAnim extends StatefulWidget {
  final Widget child;
  final Function onDismiss;
  final Offset end;

  SlideAnim({
    Key key,
    @required this.child,
    @required this.end,
    this.onDismiss,
  }) : super(key: key);

  @override
  _SlideAnimState createState() {
    return _SlideAnimState();
  }
}

class _SlideAnimState extends State<SlideAnim> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;
  Animation<Offset> _slideAnim;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    //duration 动画的时长，这里设置的 seconds: 2 为2秒，当然也可以设置毫秒 milliseconds：2000.
    controller = AnimationController(
      duration: Duration(
        milliseconds: 400,
      ),
      vsync: this,
    );
    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        if (null != widget.onDismiss) {
          widget.onDismiss();
        }
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
      } else if (status == AnimationStatus.forward) {
        //执行 controller.forward() 会回调此状态
      } else if (status == AnimationStatus.reverse) {
        //执行 controller.reverse() 会回调此状态
      }
    });

    _slideAnim = Tween(begin: Offset.zero, end: widget.end).animate(controller);
    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnim,
      child: widget.child,
    );
  }
}
