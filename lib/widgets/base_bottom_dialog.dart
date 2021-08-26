import 'package:flutter/material.dart';

import '../constants/sizes.dart';

class BottomDialog {
  static Future<dynamic> showDialog(BuildContext context, Widget content) async {
    var result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Color.fromRGBO(0, 0, 0, 0.86),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeConstant.dialogRadius),
                topRight: Radius.circular(SizeConstant.dialogRadius),
              ),
            ),
            child: content,
          ),
        );
      },
    );
    return result;
  }
}
