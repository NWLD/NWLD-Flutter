import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DialogShadowBox extends StatelessWidget {
  final Widget child;

  DialogShadowBox({Key key, @required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(boxShadow: getBoxShadows()),
      child: child,
    );
  }

  static List<BoxShadow> getBoxShadows() {
    return <BoxShadow>[
      BoxShadow(
        color: Color(0xFFA35FBC),
        offset: Offset(0.0, -6.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0xFF8C37AC),
        offset: Offset(0.0, -2.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(163, 95, 188, 1),
        offset: Offset(0.0, 6.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(140, 55, 172, 1),
        offset: Offset(0.0, 2.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.61),
        offset: Offset(0.0, 20.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(73, 27, 90, 1),
        offset: Offset(0.0, 12.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color.fromRGBO(140, 55, 172, 1),
        offset: Offset(0.0, 2.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  static List<BoxShadow> getGreenBoxShadows() {
    return <BoxShadow>[
      BoxShadow(
        color: Color(0xFF55C16A),
        offset: Offset(0.0, -6.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0xFF349F49),
        offset: Offset(0.0, -2.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0x9C000000),
        offset: Offset(0.0, 18.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0xFF174520),
        offset: Offset(0.0, 10.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
      BoxShadow(
        color: Color(0xFF349F49),
        offset: Offset(0.0, 2.w),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }
}
