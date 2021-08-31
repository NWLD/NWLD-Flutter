import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShadowContainer extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Widget child;

  ShadowContainer({
    Key key,
    @required this.width,
    @required this.height,
    @required this.color,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding:
          EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w, bottom: 10.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.w),
        boxShadow: [
          BoxShadow(
            color: Color(0x9C000000),
            offset: Offset(0, 6.w),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFF202736),
            offset: Offset(0, 4.w),
            blurRadius: 0,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFF3E4C68),
            offset: Offset(0, 2.w),
            blurRadius: 0,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
