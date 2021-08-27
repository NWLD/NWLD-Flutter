import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class DividendCard extends StatelessWidget {
  final Function onTap;
  final Color color;
  final String title;
  final String des;
  final Widget bottomChild;
  final Widget rightWidget;

  DividendCard({
    this.onTap,
    this.color,
    this.title,
    this.des,
    this.bottomChild,
    this.rightWidget,
  });

  Widget buildText(
    String text, {
    double fontSize,
    Color color,
    TextAlign textAlign = TextAlign.start,
    double height = 1.0,
  }) {
    return Text(
      text ?? "",
      textAlign: textAlign,
      style: TextStyle(
        height: height,
        color: color != null ? color : ColorConstant.title,
        fontSize: fontSize != null ? fontSize : SizeConstant.h7,
        fontFamily: 'CarterOne-Regular',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            EdgeInsets.only(left: 20.w, right: 20.w, top: 10.w, bottom: 10.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [
            BoxShadow(
              color: Color(0x9C000000),
              offset: Offset(0, 10.w),
              blurRadius: 0,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Color(0xFF202736),
              offset: Offset(0, 8.w),
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
            Image.asset(
              'dd',
              width: 140.w,
              height: 140.w,
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.w),
                  buildText(title, color: Color(0xFFD0E6F9)),
                  SizedBox(height: 10.w),
                  buildText(
                    des,
                    color: ColorConstant.teamRuleText,
                    fontSize: SizeConstant.h9,
                  ),
                  SizedBox(height: 10.w),
                  bottomChild ?? Container(),
                ],
              ),
            ),
            rightWidget ?? Container(),
          ],
        ),
      ),
    );
  }
}
