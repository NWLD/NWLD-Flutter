import 'dart:math';

import 'package:flutter/material.dart';

class GradualLinerProgress extends StatelessWidget {
  //进度比例 [0,1]
  final double rate;

  //原始宽度
  final double width;

  GradualLinerProgress({
    Key key,
    @required this.rate,
    @required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Stack(
          children: <Widget>[
            Container(
              width: width,
              height: 8,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.6),
              ),
            ),
            Positioned(
              left: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                child: Container(
                  width: max(min(1.0, rate), 0.01) * width,
                  height: 8,
                  decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                      begin: const Alignment(0.0, 0.0),
                      end: const Alignment(1.0, 0.0),
                      colors: <Color>[Color.fromRGBO(255, 168, 0, 1), Color.fromRGBO(255, 168, 0, 1)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
