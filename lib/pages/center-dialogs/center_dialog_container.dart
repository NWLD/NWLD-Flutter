import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constants/sizes.dart';

class RewardCenterContainer extends StatelessWidget {
  final String name;
  final String prefixText;
  final String icon;
  final String appendText;
  final Color color;
  final List<Widget> children;

  RewardCenterContainer({
    @required this.name,
    this.prefixText,
    this.icon,
    this.appendText,
    this.color,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 566.w,
      margin: EdgeInsets.only(top: 20.w, bottom: 50.w),
      child: Column(
        children: [
          if (prefixText != null)
            Text(
              prefixText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDBBFDE),
                fontSize: SizeConstant.h7,
                fontFamily: "CarterOne-Regular",
              ),
            ),
          Container(
            width: 566.w,
            height: 330.w,
            margin: EdgeInsets.only(top: 30.w, bottom: 10.w),
            decoration: BoxDecoration(
              color: color ?? Color.fromRGBO(86, 26, 143, 1),
              borderRadius: BorderRadius.all(Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(155, 93, 220, 0.5),
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            child: Stack(
              overflow: Overflow.visible,
              alignment: Alignment.bottomCenter,
              children: [
                if (icon != null)
                  Positioned(
                    width: 400.w,
                    child: Image.asset(icon),
                  ),
                if (children != null) ...children,
                Positioned(
                  bottom: 20.w,
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: SizeConstant.h7,
                      fontFamily: "CarterOne-Regular",
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (appendText != null)
            Text(
              appendText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDBBFDE),
                fontSize: SizeConstant.h7,
                fontFamily: "CarterOne-Regular",
              ),
            )
        ],
      ),
    );
  }
}
