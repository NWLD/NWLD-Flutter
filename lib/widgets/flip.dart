import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kingspro/widgets/image.dart';

class FlipWidget extends StatefulWidget {
  final Widget front;
  final Widget back;
  final int delay;

  FlipWidget({
    Key key,
    this.front,
    this.back,
    this.delay,
  }) : super(key: key);

  @override
  _FlipWidgetState createState() => _FlipWidgetState();
}

class _FlipWidgetState extends State<FlipWidget> {
  bool _showFrontSide; //前后
  bool _flipXAxis; //横向、纵向

  @override
  void initState() {
    super.initState();
    _showFrontSide = true;
    _flipXAxis = true;
    Future.delayed(Duration(milliseconds: widget.delay), () {
      _switchCard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: _buildFlipAnimation(),
      ),
    );
  }

  void _switchCard() {
    setState(() {
      _showFrontSide = !_showFrontSide;
    });
  }

  Widget _buildFlipAnimation() {
    return GestureDetector(
      // onTap: _switchCard,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 800),
        transitionBuilder: __transitionBuilder,
        layoutBuilder: (widget, list) => Stack(children: [widget, ...list]),
        child: _showFrontSide ? widget.front : widget.back,
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
      ),
    );
  }

  Widget __transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
    return AnimatedBuilder(
      animation: rotateAnim,
      child: widget,
      builder: (context, widget) {
        final isUnder = (ValueKey(_showFrontSide) != widget.key);
        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
        tilt *= isUnder ? -1.0 : 1.0;
        final value =
            isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
        return Transform(
          transform: _flipXAxis
              ? (Matrix4.rotationY(value)..setEntry(3, 0, tilt))
              : (Matrix4.rotationX(value)..setEntry(3, 1, tilt)),
          child: widget,
          alignment: Alignment.center,
        );
      },
    );
  }

  Widget _buildFront() {
    return ClipImage(
      key: ValueKey(true),
      width: 250,
      height: 325,
      radius: 20,
      boxColor: Colors.transparent,
      url: 'assets/card/card_back.webp',
    );
  }

  Widget _buildRear() {
    return ClipImage(
      key: ValueKey(false),
      width: 250,
      height: 325,
      radius: 20,
      boxColor: Colors.transparent,
      url: 'assets/card/card_1.jpg',
      fit: BoxFit.fitHeight,
    );
  }
}
