import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';

import '../../constants/sizes.dart';

class BottomDialogContainer extends StatelessWidget {
  final String title;
  final Color bgColor;
  final Color titleBgColor;
  final Widget content;

  BottomDialogContainer({
    @required this.content,
    this.title,
    this.bgColor,
    this.titleBgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 750.w,
      height: double.maxFinite,
      decoration: BoxDecoration(color: bgColor ?? ColorConstant.appBackground),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 750.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: titleBgColor ?? Colors.pink,
            ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(
                    left: 160.w,
                    right: 160.w,
                  ),
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConstant.h5,
                      height: 1,
                    ),
                    minFontSize: 1,
                    maxLines: 1,
                  ),
                ),
                //关闭按钮
                buildImageButton(
                  context: context,
                  image: "assets/game/ic_close.png",
                  right: 0,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 40.w,
          ),
          Expanded(child: content),
        ],
      ),
    );
  }

  Widget buildImageButton({
    BuildContext context,
    String image,
    Function onTap,
    double left,
    double right,
  }) {
    return Positioned(
      left: left,
      right: right,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        //默认值 deferToChild，表示事件只在child上执行，之前的child还是太小了
        onTapDown: (ev) {},
        onTap: () {
          if (null != onTap) {
            onTap();
            return;
          }
          Navigator.pop(context);
        },
        child: Container(
          width: 100.w,
          height: 100.w,
          alignment: Alignment.center,
          child: Image.asset(
            image,
            width: 78.w,
            height: 78.w,
          ),
        ),
      ),
    );
  }
}
