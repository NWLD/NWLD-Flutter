import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../util/string_util.dart';
import '../../widgets/toast_util.dart';
import 'bottom_dialog_container.dart';

class TransferDialog extends StatefulWidget {
  @override
  _TransferDialogState createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog>
    with BaseLocalizationsStateMixin {
  TextEditingController addressEditingController;
  TextEditingController amountEditingController;

  @override
  void initState() {
    amountEditingController = TextEditingController();
    addressEditingController = TextEditingController();
    super.initState();
  }

  Widget buildTextField({
    TextEditingController editingController,
    double height,
    String hint,
    int maxLines,
    bool num,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 20.w),
      constraints: BoxConstraints(minHeight: height),
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFFDFFFF),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: editingController,
        onChanged: (value) {
          setState(() {});
        },
        expands: true,
        maxLines: null,
        minLines: null,
        scrollPadding: EdgeInsets.all(0),
        keyboardType: num
            ? TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: ColorConstant.appBackground,
          fontSize: SizeConstant.h7,
          height: 1.25,
        ),
        decoration: InputDecoration(
          hintText: hint,
          contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            color: ColorConstant.des,
          ),
        ),
      ),
    );
  }

  Widget buildAmountTextField() {
    return buildTextField(
      editingController: amountEditingController,
      height: 80.w,
      hint: $t('输入转账数额'),
      num: true,
    );
  }

  Widget buildAddressTextField() {
    return buildTextField(
      editingController: addressEditingController,
      height: 120.w,
      hint: $t('输入转账地址'),
      num: false,
    );
  }

  buildTransferButton() {
    return TouchDownScale(
      child: ShadowContainer(
        width: 630.w,
        height: 96.w,
        color: ColorConstant.titleBg,
        margin: EdgeInsets.all(60.w),
        child: Center(
          child: Text(
            $t('转账'),
            style: TextStyle(
              color: ColorConstant.title,
              fontSize: SizeConstant.h7,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      onTap: () async {
        String address = '';
        if (null != addressEditingController.text) {
          address = addressEditingController.text.trim();
        }
        if (StringUtils.isEmpty(address)) {
          ToastUtil.showToast(
            $t('请输入转账地址'),
            type: ToastType.warning,
          );
          return;
        }
        String amount = '';
        if (null != amountEditingController.text) {
          amount = amountEditingController.text.trim();
        }
        if (StringUtils.isEmpty(amount)) {
          ToastUtil.showToast(
            $t('请输入转账数额'),
            type: ToastType.warning,
          );
          return;
        }
        if (!address.startsWith("0x")) {
          ToastUtil.showToast(
            $t('地址格式错误'),
            type: ToastType.warning,
          );
          return;
        }
        try {
          EasyLoading.show(dismissOnTap: true);
          String hash = await TransactionService.send(address, amount);
          setState(() {
            addressEditingController.text = '';
            amountEditingController.text = '';
          });
          confirmBuy(hash);
        } catch (e) {
          ToastUtil.showToast(
            e.toString(),
            type: ToastType.error,
          );
        } finally {
          EasyLoading.dismiss();
        }
      },
    );
  }

  PeriodicTimer _buyPeriodicTimer;

  void confirmBuy(String hash) async {
    EasyLoading.show(dismissOnTap: true);
    if (null != _buyPeriodicTimer) {
      return;
    }
    _buyPeriodicTimer = PeriodicTimer();
    _buyPeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _buyPeriodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _buyPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('转账失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _buyPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('转账成功'), type: ToastType.success);
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        EasyLoading.dismiss();
        _cancelBuyPeriodicTimer();
      },
    );
  }

  void _cancelBuyPeriodicTimer() {
    if (null != _buyPeriodicTimer) {
      _buyPeriodicTimer.cancel(false);
      _buyPeriodicTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t('转账'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 40.w, right: 40.w),
              child: AutoFontSizeText(
                text: null == AccountModel.getInstance().balance
                    ? ''
                    : NumberUtil.decimalNumString(
                          num: AccountModel.getInstance().balance.toString(),
                          fractionDigits: 4,
                        ) +
                        ' ' +
                        SettingsModel().currentChain().symbol,
                minfontSize: 10,
                style: TextStyle(
                  fontSize: SizeConstant.h7,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildAddressTextField(),
            buildAmountTextField(),
            buildTransferButton(),
          ],
        ),
      ),
    );
  }
}
