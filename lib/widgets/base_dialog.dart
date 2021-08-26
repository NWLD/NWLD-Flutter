import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'primary_button.dart';

import '../constants/sizes.dart';
import '../l10n/base_localizations.dart';

class BaseDialogContainer {
  static Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // 使用缩放动画
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }

  //放大弹框
  static Future<dynamic> showDialog({
    BuildContext context,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black54,
    WidgetBuilder builder,
    Widget child, // 与 builder 互斥，优先 child
  }) async {
    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      // 自定义遮罩颜色
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: _buildMaterialDialogTransitions,

      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        final Widget pageChild = child ?? Builder(builder: builder);
        return pageChild;
      },
    );
  }

  static Future<dynamic> showDialogWithAd({
    BuildContext context,
    bool barrierDismissible = true,
    Color barrierColor = Colors.black87,
    WidgetBuilder builder,
    Widget child, // 与 builder 互斥，优先 child
  }) async {
    var result = await BaseDialogContainer.showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      builder: builder,
      child: child,
    );
    return result;
  }
}

class BaseAlertDialog extends StatelessWidget {
  final String title;
  final Widget child;
  final Function onConfirm;

  BaseAlertDialog({
    this.title,
    this.child,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    Function $t = create$t(context);

    return UnconstrainedBox(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        constraints: BoxConstraints(minWidth: 600.w, maxWidth: 600.w),
        padding: EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: SizeConstant.h6,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            child,
            SizedBox(height: 20),
            PrimaryButton(
              title: $t('确定'),
              onTap: () {
                if (onConfirm != null) {
                  onConfirm();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 单纯的一个 confirm 对话框，附带确认、取消按钮
class BaseConfirmDialog extends BaseAlertDialog {
  final String title;
  final Widget child;
  final Function onConfirm;
  final Function onCancel;

  BaseConfirmDialog({
    this.title,
    this.child,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: SizeConstant.h6,
        ),
      ),
      content: child,
      actions: [
        FlatButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel();
            }
            // 如果有 cancel，手动触发 pop
            else {
              Navigator.pop(context);
            }
          },
          child: Text('取消'),
        ),
        FlatButton(
          onPressed: () {
            if (onConfirm != null) {
              onConfirm();
            } else {
              Navigator.pop(context);
            }
          },
          child: Text('确定'),
        ),
      ],
    );
  }
}
