import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import 'touch_down_scale.dart';

class TitleWidget {
  static AppBar createAppBar({
    BuildContext context,
    String title,
    String rightText,
    Function rightClick,
    Color backgroundColor,
  }) {
    return AppBar(
      titleSpacing: 0,
      leadingWidth: 0,
      backgroundColor: backgroundColor ?? ColorConstant.appBackground,
      automaticallyImplyLeading: false,
      elevation: 0,
      title: Container(
        height: kToolbarHeight,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 80, right: 80),
              child: Text(
                title ?? "",
                style: TextStyle(
                  fontSize: SizeConstant.h7,
                  color: ColorConstant.title,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              child: TouchDownScale(
                child: Container(
                  alignment: Alignment.centerLeft,
                  width: 55,
                  height: kToolbarHeight,
                  child: Image.asset(
                    'assets/abc/back.png',
                    width: 55,
                    height: 38,
                  ),
                ),
                onTap: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            Positioned(
              right: 20,
              top: 0,
              child: TouchDownScale(
                child: Container(
                  alignment: Alignment.center,
                  height: kToolbarHeight,
                  child: Text(
                    rightText ?? "",
                    style: TextStyle(
                      fontSize: SizeConstant.h7,
                      color: ColorConstant.title,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  if (null != rightClick) {
                    rightClick();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
