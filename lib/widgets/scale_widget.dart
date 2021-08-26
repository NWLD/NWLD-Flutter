import 'package:flutter/material.dart';

///缩放
class Scale extends StatefulWidget {
  final Widget child;
  final double lowerBound;
  final double upperBound;
  final double value;
  final bool start;
  final bool repeat;
  final int duration;
  final int reverseDuration;
  final Alignment alignment;

  Scale({
    Key key,
    @required this.child,
    this.lowerBound = 0,
    this.upperBound = 1,
    this.value = 0,
    this.start = false,
    this.repeat = false,
    this.duration = 150,
    this.reverseDuration = 150,
    this.alignment = Alignment.center,
  }) : super(key: key);

  @override
  _ScaleState createState() {
    return new _ScaleState();
  }
}

class _ScaleState extends State<Scale> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;

  forward() {
    controller.forward();
  }

  reverse() {
    controller.reverse();
  }

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    //duration 动画的时长，这里设置的 seconds: 2 为2秒，当然也可以设置毫秒 milliseconds：2000.
    controller = AnimationController(
        value: widget.value,
        duration: Duration(
          milliseconds: widget.duration,
        ),
        reverseDuration: Duration(
          milliseconds: widget.reverseDuration,
        ),
        lowerBound: widget.lowerBound,
        upperBound: widget.upperBound,
        vsync: this);
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
    if (widget.start) {
      if (widget.repeat) {
        controller.repeat(reverse: true);
      } else {
        controller.forward(from: widget.lowerBound);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      alignment: widget.alignment,
      child: Container(
        child: widget.child,
      ),
      scale: controller,
    );
  }
}

///先放大，再缩小
class SpringScale extends StatefulWidget {
  final Widget child;
  final double lowerBound;
  final double upperBound;
  final double value;

  SpringScale({
    Key key,
    @required this.child,
    this.lowerBound = 0,
    this.upperBound = 1.2,
    this.value = 1,
  }) : super(key: key);

  @override
  SpringScaleState createState() {
    return SpringScaleState();
  }
}

class SpringScaleState extends State<SpringScale> with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;
  Animation _animation;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    //duration 动画的时长，这里设置的 seconds: 2 为2秒，当然也可以设置毫秒 milliseconds：2000.
    controller = AnimationController(
      duration: Duration(
        milliseconds: 300,
      ),
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

    _animation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: widget.lowerBound, end: widget.upperBound).chain(CurveTween(curve: Curves.easeIn)), weight: 70),
      TweenSequenceItem(tween: Tween(begin: widget.upperBound, end: widget.value).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
    ]).animate(controller);

    controller.forward(from: widget.lowerBound);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      child: widget.child,
      scale: _animation,
    );
  }
}
