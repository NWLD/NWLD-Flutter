import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/GasInfo.dart';
import 'package:kingspro/entity/TransactionInfo.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/base_button.dart';
import 'package:kingspro/widgets/toast_util.dart';

import '../../l10n/base_localizations.dart';
import 'bottom_dialog_container.dart';

class TransactionConfirmDialog extends StatefulWidget {
  static Future<String> send(
    BuildContext buildContext,
    TransactionInfo transactionInfo,
  ) async {
    EasyLoading.show();
    try {
      GasInfo gasInfo =
          await TransactionService.estimateGas(transactionInfo.transaction);
      transactionInfo.transaction = gasInfo.transaction;
      EasyLoading.dismiss();
      dynamic result = await BottomDialog.showDialog(
        buildContext,
        TransactionConfirmDialog(
          transactionInfo: transactionInfo,
        ),
      );
      return result;
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
      EasyLoading.dismiss();
      return null;
    }
  }

  final TransactionInfo transactionInfo;

  TransactionConfirmDialog({Key key, this.transactionInfo}) : super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<TransactionConfirmDialog>
    with BaseLocalizationsStateMixin {
  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("交易详情"),
      content: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  alignment: AlignmentDirectional.center,
                  margin: EdgeInsets.only(bottom: 60.w, top: 20.w),
                  child: Text(
                    widget.transactionInfo.value,
                    style: TextStyle(
                      color: ColorConstant.title,
                      fontSize: SizeConstant.h7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                buildItem(
                  '收款地址',
                  widget.transactionInfo.transaction.to.hexEip55,
                  null,
                ),
                buildItem(
                  '手续费',
                  widget.transactionInfo.gasLabel() +
                      ' ' +
                      SettingsModel.getInstance().currentChain().symbol,
                  widget.transactionInfo.gasDetail(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 60.w,
              bottom: 60.w,
              left: 40.w,
              right: 40.w,
            ),
            child: Row(
              children: [
                Expanded(
                  child: BaseButton(
                    title: $t('取消'),
                    bg: ColorConstant.bg_level_9,
                    onTap: _cancel,
                  ),
                ),
                SizedBox(
                  width: 60.w,
                ),
                Expanded(
                  child: BaseButton(
                    title: $t('确认支付'),
                    onTap: _confirm,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildItem(String key, String value, String des) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: ColorConstant.des, width: 1.w),
        ),
      ),
      padding: EdgeInsets.only(top: 20.w, bottom: 20.w),
      margin: EdgeInsets.only(left: 40.w, right: 40.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.w,
            margin: EdgeInsets.only(right: 20.w),
            child: Text(
              key,
              style: TextStyle(
                color: ColorConstant.title,
                fontSize: SizeConstant.h9,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: ColorConstant.title,
                    fontWeight: FontWeight.bold,
                    fontSize: SizeConstant.h8,
                  ),
                ),
                if (null != des)
                  SizedBox(
                    height: 6.w,
                  ),
                if (null != des)
                  Text(
                    des,
                    style: TextStyle(
                      color: ColorConstant.title,
                      fontSize: SizeConstant.h10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  void _confirm() async {
    EasyLoading.show();
    try {
      String hash =
          await TransactionService.send(widget.transactionInfo.transaction);
      Navigator.of(context).pop(hash);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    } finally {
      EasyLoading.dismiss();
    }
  }
}
