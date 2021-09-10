import 'package:flutter/material.dart';

///按下缩放
class TouchDownScale extends StatefulWidget {
  final Widget child;
  final double fromScale;
  final double toScale;
  final bool isScaleDown;
  final bool hasSound;
  final Function onTap;
  final Function onTapDown;

  TouchDownScale({
    Key key,
    @required this.child,
    this.fromScale = 1,
    this.toScale = 0.9,
    this.hasSound = false,
    this.onTap,
    this.onTapDown,
  })  : isScaleDown = toScale < fromScale,
        super(key: key);

  @override
  _TouchDownScaleState createState() => _TouchDownScaleState();
}

class _TouchDownScaleState extends State<TouchDownScale>
    with TickerProviderStateMixin {
  //动画控制器
  AnimationController controller;
  bool pointerUp = false;
  bool isHalfDone = false;

  @override
  void initState() {
    //vsync参数，存在vsync时会防止屏幕外动画（动画的UI不在当前屏幕时）消耗不必要的资源
    controller = AnimationController(
      value: 1,
      duration: Duration(milliseconds: 100),
      reverseDuration: Duration(milliseconds: 100),
      lowerBound: widget.isScaleDown ? widget.toScale : widget.fromScale,
      upperBound: widget.isScaleDown ? widget.fromScale : widget.toScale,
      vsync: this,
    );

    //动画开始、结束、向前移动或向后移动时会调用StatusListener
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //动画从 controller.forward() 正向执行 结束时会回调此方法
        if (!widget.isScaleDown) {
          halfDone();
        }
      } else if (status == AnimationStatus.dismissed) {
        //动画从 controller.reverse() 反向执行 结束时会回调此方法
        if (widget.isScaleDown) {
          halfDone();
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

  halfDone() {
    isHalfDone = true;

    if (pointerUp) {
      forward();
    }
  }

  forward() {
    if (widget.isScaleDown) {
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  reverse() {
    if (widget.isScaleDown) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        pointerUp = false;
        isHalfDone = false;
        reverse();

        if (widget.onTapDown != null) widget.onTapDown(event);
      },
      onPointerUp: (event) {
        pointerUp = true;

        if (isHalfDone) {
          forward();
        }

        if (widget.onTap != null) widget.onTap();
      },
      // 动画上等同于 onTapUp
      onPointerCancel: (event) {
        pointerUp = true;

        if (isHalfDone) {
          forward();
        }
      },
      child: ScaleTransition(
        scale: controller,
        child: widget.child,
      ),
    );
  }
}
