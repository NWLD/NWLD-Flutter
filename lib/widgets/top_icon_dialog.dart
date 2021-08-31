import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'primary_button.dart';
import 'shadow_box.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import 'button_close.dart';

class TopIconDialog extends StatefulWidget {
  final String title; //标题
  final Widget content; //中间内容
  final String buttonTitle; //按钮文案
  final Widget button; // 自定义按钮，与 buttonTitle 不兼容
  final String bottomDesc; //按钮底部描述
  final Widget bottom; //按钮底部内容
  final Color backgroundColor; //背景颜色
  final String dismissImagePath; //关闭按钮图片路径
  final Widget trialWidget; //尾部控件
  final bool showClose; //显示关闭按钮

  final Function onConfirm; //确认按钮方法
  final Function onClose; //关闭按钮方法
  final List<BoxShadow> shadows;

  TopIconDialog({
    Key key,
    @required this.title,
    @required this.content,
    this.buttonTitle,
    this.button,
    this.onConfirm,
    this.onClose,
    this.bottomDesc,
    this.bottom,
    this.backgroundColor,
    this.dismissImagePath,
    this.trialWidget,
    this.showClose = true,
    this.shadows,
  }) : super(key: key);

  @override
  _TopIconDialogState createState() => _TopIconDialogState();
}

class _TopIconDialogState extends State<TopIconDialog> {
  List<BoxShadow> getBoxShadows() {
    if (widget.shadows == null) {
      return DialogShadowBox.getBoxShadows();
    } else {
      return widget.shadows;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget button = widget.button ??
        PrimaryButton(
          title: widget.buttonTitle,
          width: 580.w,
          onTap: () {
            if (widget.onConfirm == null) {
              Navigator.pop(context);
            } else {
              widget.onConfirm();
            }
          },
        );

    return WillPopScope(
      //创建透明层
      onWillPop: () async => false, //重点此举
      //保证控件居中效果
      child: Material(
        type: MaterialType.transparency, //透明类型
        child: Container(
          alignment: AlignmentDirectional.center,
          width: 1200.w,
          constraints: BoxConstraints(maxHeight: 1200.w),
          margin: EdgeInsets.all(35.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: AlignmentDirectional.center,
                overflow: Overflow.visible,
                children: [
                  Positioned(
                    child: Container(
                      width: 1200.w,
                      margin: EdgeInsets.only(top: 58.w, bottom: widget.bottom == null ? 58.w : 0),
                      padding: EdgeInsets.only(
                        top: 50.w,
                        bottom: 64.w,
                      ),
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ?? Color.fromRGBO(140, 55, 172, 1),
                        image: DecorationImage(
                          image: AssetImage(
                            "assets/mine/bg_texture.png",
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20.w)),
                        boxShadow: getBoxShadows(),
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20.w, right: 20.w),
                            child: Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: SizeConstant.h4,
                                color: Colors.white,
                                fontFamily: "CarterOne-Regular",
                              ),
                            ),
                          ),
                          if (widget.content != null) widget.content,
                          button,
                          if (widget.bottomDesc != null)
                            Text(
                              widget.bottomDesc,
                              style: TextStyle(color: ColorConstant.notice, fontSize: SizeConstant.h10),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 45.w,
                    right: -8.w,
                    child: widget.showClose
                        ? ButtonClose(
                            onClose: widget.onClose,
                          )
                        : Container(),
                  ),
                ],
              ),
              if (widget.bottom != null) widget.bottom,
              if (widget.bottom != null) SizedBox(height: 58.w),
            ],
          ),
        ),
      ),
    );
  }
}
