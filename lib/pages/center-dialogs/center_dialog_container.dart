import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/sizes.dart';

class CenterDialogContainer extends StatelessWidget {
  final String title;
  final String content;
  final String cancel;
  final String confirm;
  final Function onConfirm;

  CenterDialogContainer({
    @required this.title,
    this.content,
    this.cancel,
    this.confirm,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.w),
          child: Container(
            width: 630.w,
            color: ColorConstant.appBackground,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 630.w,
                  height: 96.w,
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                    color: ColorConstant.titleBg,
                  ),
                  child: AutoFontSizeText(
                    text: title ?? "title",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ColorConstant.title,
                      fontSize: SizeConstant.h5,
                      height: 1,
                    ),
                    minfontSize: 10,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(40.w),
                  child: Text(
                    content ?? "content",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: ColorConstant.title,
                      fontSize: SizeConstant.h7,
                      height: 1.3,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TouchDownScale(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: ShadowContainer(
                          margin: EdgeInsets.all(40.w),
                          height: 80.w,
                          child: Center(
                            child: Text(
                              cancel ?? "cancel",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorConstant.title,
                                fontSize: SizeConstant.h7,
                                height: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TouchDownScale(
                        onTap: () {
                          if (null != onConfirm) {
                            onConfirm();
                          }
                          Navigator.of(context).pop();
                        },
                        child: ShadowContainer(
                          height: 80.w,
                          color: ColorConstant.titleBg,
                          margin: EdgeInsets.all(40.w),
                          child: Center(
                            child: Text(
                              confirm ?? "confirm",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: ColorConstant.title,
                                fontSize: SizeConstant.h7,
                                height: 1,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
