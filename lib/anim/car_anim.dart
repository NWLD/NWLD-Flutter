import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/sizes.dart';
import 'coin_rive_anim.dart';
import 'slide_scale_anim.dart';

class Car {
  int pathSeconds;
  int pos;
  String perCoin;
  String icon;
  int level;
  bool isEnd = false;

  Car({
    this.icon,
    this.pos,
    this.pathSeconds,
    this.perCoin,
    this.level,
  });
}

typedef CarPathHandler = void Function(Car car, double progress);

class CarPathController {
  CarPathHandler onPathEnd;
  CarPathHandler onRemoved;
}

class CarAnimation extends StatefulWidget {
  final Car car;
  final CarPathController controller;

  CarAnimation({
    Key key,
    this.car,
    this.controller,
  }) : super(key: key);

  @override
  _CarAnimationState createState() => _CarAnimationState();
}

class _CarAnimationState extends State<CarAnimation>
    with TickerProviderStateMixin {
  AnimationController _controller;

  double carWidth = 80;
  double carHeight = 50;
  double top = 10000000;
  double left = 0;
  double rotate = 0;

  double minLeft = 0;
  double maxLeft = 0;
  double minTop = 0;
  double maxTop = 0;

  double endY;

  VoidCallback animationListener;

  bool coinAnimation = false;
  bool textAnimation = false;

  final double maxValue = 2.0;

  @override
  void initState() {
    carWidth = 44.w;
    carHeight = 150.w;
    minLeft = 28.w;
    maxLeft = 750.w - carWidth - 28.w;
    minTop = -carHeight;
    _controller = AnimationController(
      value: math.Random().nextDouble(),
      // 初始位置随机
      vsync: this,
      lowerBound: 0.0,
      upperBound: maxValue,
      duration: Duration(seconds: widget.car.pathSeconds),
    );
    animationListener = () {
      if (isRemoved || !mounted) {
        return;
      }
      setPosition(_controller.value);
    };
    _controller.addListener(animationListener);
    _controller.repeat();
    super.initState();
  }

  bool isRemoved = false;

  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    isRemoved = true;
    double progress = _controller.value / maxValue;
    _controller.removeListener(animationListener);
    _controller.dispose();
    if (null != widget.controller && null != widget.controller.onRemoved) {
      widget.controller.onRemoved(widget.car, progress);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        maxTop = constraints.maxHeight + carHeight;
        endY = constraints.maxHeight / 2;
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              //TODO 改为Transform实现
              Positioned(
                left: left,
                top: top,
                child: Transform.rotate(
                  angle: rotate,
                  child: Image.asset(
                    widget.car.icon,
                    width: carWidth,
                    height: carHeight,
                  ),
                ),
              ),
              Positioned(
                right: -55.w,
                top: endY - 110.w,
                child: Container(
                  width: 220.w,
                  height: 220.w,
                  alignment: Alignment.center,
                  child: !coinAnimation ? Container() : CoinRiveAnimation(),
                ),
              ),
              Positioned(
                right: 0,
                top: endY - 110.w + 78.w,
                child: Container(
                  constraints: BoxConstraints(minWidth: 110.w),
                  height: 220.w,
                  alignment: Alignment.topCenter,
                  child: !textAnimation
                      ? Container()
                      : SlideScaleAnim(
                          onDismiss: () {
                            setState(() {
                              coinAnimation = false;
                              textAnimation = false;
                            });
                          },
                          child: Text(
                            "+",
                            style: TextStyle(
                              fontSize: SizeConstant.h8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void setPosition(double value) {
    double width = maxLeft - minLeft;
    double height = maxTop - minTop;

    if (!mounted) {
      return;
    }

    setState(() {
      if (value <= 1) {
        double tempTop = maxTop - value * height;
        top = tempTop > minTop ? tempTop : minTop;
        left = minLeft;
        rotate = 0;
        widget.car.isEnd = false;
        return;
      }
      // if (value <= 1.5) {
      //   double tempLeft = width * (value - 1) * 2;
      //   left = tempLeft < maxLeft ? tempLeft : maxLeft;
      //   top = minTop;
      //   rotate = math.pi;
      //   return;
      // }
      if (value <= 2) {
        double tempTop = minTop + height * (value - 1);
        //跑道动画结束
        if (!widget.car.isEnd && tempTop >= endY - carHeight - 80.w) {
          coinAnimation = true;
          textAnimation = true;
          widget.car.isEnd = true;
          if (null != widget.controller &&
              null != widget.controller.onPathEnd) {
            widget.controller.onPathEnd(widget.car, 1.0);
          }
        }
        top = tempTop < maxTop ? tempTop : maxTop;
        left = maxLeft;
        rotate = math.pi;
        return;
      }
      // if (value <= 3) {
      //   double tempLeft = width - width * 2 * (value - 2.5);
      //   left = tempLeft > minLeft ? tempLeft : minLeft;
      //   top = minTop;
      //   rotate = math.pi;
      //   return;
      // }
    });
  }
}
