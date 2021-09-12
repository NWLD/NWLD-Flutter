import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/pages/center-dialogs/center_dialog_container.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/base_button.dart';
import 'package:kingspro/widgets/base_dialog.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../util/string_util.dart';
import '../../widgets/toast_util.dart';
import 'bottom_dialog_container.dart';

class LoginDialog extends StatefulWidget {
  static bool shouldShow(BuildContext buildContext) {
    if (AccountModel.getInstance().isNull()) {
      show(buildContext);
      return true;
    }
    return false;
  }

  static bool show(BuildContext buildContext) {
    BottomDialog.showDialog(buildContext, LoginDialog());
  }

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with BaseLocalizationsStateMixin {
  TextEditingController addressEditingController;
  TextEditingController nameEditingController;

  @override
  void initState() {
    nameEditingController = TextEditingController();
    addressEditingController = TextEditingController();
    super.initState();
  }

  Widget buildTextField({
    TextEditingController editingController,
    double height,
    String hint,
    int maxLines,
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

  Widget buildNameTextField() {
    return buildTextField(
      editingController: nameEditingController,
      height: 80.w,
      hint: $t('请设置账户名'),
    );
  }

  Widget buildAddressTextField() {
    return buildTextField(
      editingController: addressEditingController,
      height: 120.w,
      hint: $t('请填写私钥'),
    );
  }

  buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: 40.w),
        Expanded(child: buildImportButton()),
        SizedBox(width: 40.w),
        Expanded(child: buildCreateButton()),
        SizedBox(width: 40.w),
      ],
    );
  }

  buildImportButton() {
    return BaseButton(
      title: $t('导入账户'),
      onTap: () async {
        String name = '';
        if (null != nameEditingController.text) {
          name = nameEditingController.text.trim();
        }

        String privateKey = '';
        if (null != addressEditingController.text) {
          privateKey = addressEditingController.text.trim();
        }
        if (StringUtils.isEmpty(name)) {
          ToastUtil.showToast(
            $t('请设置账户名'),
            type: ToastType.warning,
          );
          return;
        }
        if (StringUtils.isEmpty(privateKey)) {
          ToastUtil.showToast(
            $t('请填写私钥'),
            type: ToastType.warning,
          );
          return;
        }
        if (!privateKey.startsWith("0x") || 66 != privateKey.length) {
          ToastUtil.showToast(
            $t('私钥格式错误'),
            type: ToastType.warning,
          );
          return;
        }
        try {
          Credentials fromHex = EthPrivateKey.fromHex(privateKey);
          final address = await fromHex.extractAddress();
          String encodePrivateKey = AccountModel().encodePrivateKey(privateKey);
          AccountModel.getInstance().updateAccount(
            account: address.hexEip55,
            name: name,
            privateKey: encodePrivateKey,
          );
          Navigator.of(context).pop();
        } catch (e) {
          ToastUtil.showToast(
            $t('私钥格式错误'),
            type: ToastType.warning,
          );
          print(e);
          throw e;
        } finally {}
      },
    );
  }

  buildCreateButton() {
    return BaseButton(
      title: $t('创建新账户'),
      onTap: () async {
        String name = '';
        if (null != nameEditingController.text) {
          name = nameEditingController.text.trim();
        }
        if (StringUtils.isEmpty(name)) {
          ToastUtil.showToast(
            $t('请设置账户名'),
            type: ToastType.warning,
          );
          return;
        }
        try {
          var random = new Random.secure();
          EthPrivateKey credentials = EthPrivateKey.createRandom(random);
          var address = await credentials.extractAddress();
          String privateKey =
              '0x' + credentials.privateKeyInt.toRadixString(16);
          String encodePrivateKey = AccountModel().encodePrivateKey(privateKey);
          AccountModel.getInstance().updateAccount(
            account: address.hexEip55,
            name: name,
            privateKey: encodePrivateKey,
          );
          Navigator.of(context).pop();
          showPrivateKey();
        } catch (e) {
          print(e);
          throw e;
        } finally {}
      },
    );
  }

  void showPrivateKey() {
    if (LoginDialog.shouldShow(context)) {
      return;
    }
    BaseDialogContainer.showDialog(
      context: context,
      child: CenterDialogContainer(
        title: $t('备份私钥'),
        content: AccountModel.getInstance().decodePrivateKey(),
        cancel: $t('关闭'),
        confirm: $t('复制'),
        onConfirm: () {
          ClipboardData data = new ClipboardData(
            text: AccountModel.getInstance().decodePrivateKey(),
          );
          Clipboard.setData(data);
          ToastUtil.showToast(
            $t("已复制"),
            type: ToastType.success,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t('登录'),
      content: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildNameTextField(),
            buildAddressTextField(),
            SizedBox(
              height: 40.w,
            ),
            buildButtons(),
          ],
        ),
      ),
    );
  }
}
