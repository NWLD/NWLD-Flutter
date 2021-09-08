import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';

import '../constants/sizes.dart';
import 'touch_down_scale.dart';

class BaseButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final num width;
  final num height;
  final double fontSize;
  final Color color;

  BaseButton({
    Key key,
    @required this.title,
    @required this.onTap,
    this.width,
    this.height,
    this.fontSize,
    this.color,
  }) : super(key: key);

  buildChild() {
    Widget childTitle = Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize ?? SizeConstant.h7,
      ),
      textAlign: TextAlign.center,
    );
    return childTitle;
  }

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w, bottom: 10.w),
        decoration: BoxDecoration(
          color: color ?? ColorConstant.titleBg,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: buildChild()),
          ],
        ),
      ),
    );
  }
}
