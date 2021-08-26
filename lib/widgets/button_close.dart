import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ButtonClose extends StatelessWidget {
  final Function onClose; //关闭按钮方法

  ButtonClose({
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (ev) {},
      onTap: () {
        if (onClose != null) {
          onClose();
        }
        Navigator.pop(context);
      },
      child: Image.asset(
        "assets/mine/popview_dismiss.png",
        width: 111.w,
        height: 76.w,
      ),
    );
  }
}
