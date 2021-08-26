import 'package:flutter/material.dart';

class SlideScaleAnim extends StatefulWidget {
  final Widget child;
  final Function onDismiss;

  SlideScaleAnim({
    Key key,
    @required this.child,
    this.onDismiss,
  }) : super(key: key);

  @override
  _SlideScaleAnimState createState() {
    return _SlideScaleAnimState();
  }
}

class _SlideScaleAnimState extends State<SlideScaleAnim> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;
  Animation _scaleAnim;
  Animation<Offset> _slideAnim;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    //duration 动画的时长，这里设置的 seconds: 2 为2秒，当然也可以设置毫秒 milliseconds：2000.
    controller = AnimationController(
        duration: Duration(
          milliseconds: 650,
        ),
        vsync: this);
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

    _scaleAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 85),
    ]).animate(controller);

    _slideAnim = Tween(begin: Offset.zero, end: Offset(0.0, -1.0)).animate(controller);
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
      child: ScaleTransition(
        child: widget.child,
        scale: _scaleAnim,
      ),
    );
  }
}
