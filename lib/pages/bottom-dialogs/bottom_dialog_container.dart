import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/sizes.dart';

class BottomDialogContainer extends StatelessWidget {
  final String title;
  final String backgroundImagePath;
  final Widget content;
  final Widget floatWidget;
  final EdgeInsetsGeometry contentMargin;
  final bool showBack;
  final Function backClick;

  BottomDialogContainer({
    @required this.title,
    @required this.backgroundImagePath,
    @required this.content,
    this.floatWidget,
    this.contentMargin,
    this.showBack = false,
    this.backClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 750.w,
      height: 663.w,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            this.backgroundImagePath,
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          buildContent(),
          Positioned(
            top: 10.w,
            left: 160.w,
            right: 160.w,
            child: Container(
              alignment: Alignment.center,
              height: 60.w,
              child: AutoSizeText(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(208, 230, 249, 1),
                  fontSize: SizeConstant.h5,
                  fontFamily: "CarterOne-Regular",
                  height: 1,
                ),
                minFontSize: 1,
                maxLines: 1,
              ),
            ),
          ),
          //关闭按钮
          buildImageButton(
            context: context,
            image: "assets/game/ic_close.png",
            right: 25.w,
          ),
          //返回按钮
          !showBack
              ? Container()
              : buildImageButton(
                  context: context,
                  image: "assets/common/dialog_back.png",
                  onTap: backClick,
                  left: 25.w,
                ),
          this.floatWidget != null
              ? this.floatWidget
              : SizedBox(
                  height: 0.1,
                )
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
      top: 60.w,
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
          // color: Colors.green,
          width: 120.w,
          height: 120.w,
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

  Widget buildContent() {
    EdgeInsets margin = contentMargin ??
        EdgeInsets.only(
          top: 170.w,
          left: 20.w,
          bottom: 34.w,
          right: 20.w,
        );
    return Positioned(
      top: margin.top,
      left: margin.left,
      bottom: margin.bottom,
      right: margin.right,
      child: Container(
        child: content,
      ),
    );
  }
}
