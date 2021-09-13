import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/widgets/shadow_container.dart';

import '../constants/sizes.dart';
import 'touch_down_scale.dart';

class BaseButton extends StatelessWidget {
  final String title;
  final Function onTap;
  final double fontSize;
  final Color color;

  final Color bg;
  final double width;
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  BaseButton({
    Key key,
    @required this.title,
    @required this.onTap,
    this.width,
    this.height,
    this.fontSize,
    this.color,
    this.bg,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: onTap,
      child: ShadowContainer(
        width: width ?? 630.w,
        height: height ?? 96.w,
        padding: padding ?? EdgeInsets.all(10.w),
        margin: margin,
        color: bg ?? ColorConstant.titleBg,
        child: Center(
          child: Text(
            title ?? 'Button',
            style: TextStyle(
              color: color ?? ColorConstant.title,
              fontSize: fontSize ?? SizeConstant.h7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
