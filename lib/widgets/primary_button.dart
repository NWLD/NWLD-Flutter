import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/sizes.dart';
import 'touch_down_scale.dart';

class PrimaryButton extends StatelessWidget {
  final String title;
  final Widget prefix;
  final Function onTap;
  final bool disabled;
  final num width;

  PrimaryButton({
    Key key,
    @required this.title,
    @required this.onTap,
    this.prefix,
    this.disabled = false,
    this.width,
  }) : super(key: key);

  buildChild() {
    Widget childTitle = Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: SizeConstant.h4,
      ),
    );

    if (prefix == null) {
      return childTitle;
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          prefix,
          SizedBox(width: 10.w),
          childTitle,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        height: 100.w,
        width: width,
        padding: EdgeInsets.only(bottom: 6.w),
        constraints: BoxConstraints(minWidth: 204.w, minHeight: 100.w),
        decoration: BoxDecoration(
          image: DecorationImage(
            centerSlice: Rect.fromLTWH(30, 10, 160, 35),
            image: AssetImage(
              disabled
                  ? 'assets/common/button_disable.9.png'
                  : 'assets/common/button_normal.9.png',
            ),
          ),
        ),
        child: this.buildChild(),
      ),
    );
  }
}
