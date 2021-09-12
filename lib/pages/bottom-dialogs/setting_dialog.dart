import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/transfer_dialog.dart';
import 'package:kingspro/pages/center-dialogs/center_dialog_container.dart';
import 'package:kingspro/util/client_utils.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/base_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import 'bottom_dialog_container.dart';

class SettingDialog extends StatefulWidget {
  @override
  _SettingDialogState createState() => _SettingDialogState();
}

class _SettingDialogState extends State<SettingDialog>
    with BaseLocalizationsStateMixin {
  String ver = '1.0';

  @override
  void initState() {
    getAppVer();
    super.initState();
  }

  void getAppVer() async {
    String version = await ClientUtils.getAppVersion();
    setState(() {
      ver = version;
    });
  }

  @override
  dispose() {
    super.dispose();
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

  Widget buildItem(String title, String des, Function onTap) {
    return TouchDownScale(
      onTap: onTap,
      child: ShadowContainer(
        margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        height: 96.w,
        color: ColorConstant.titleBg,
        child: Container(
          alignment: AlignmentDirectional.centerStart,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title ?? "",
                  style: TextStyle(
                    color: ColorConstant.title,
                    fontSize: SizeConstant.h7,
                  ),
                ),
              ),
              Text(
                des ?? "",
                style: TextStyle(
                  color: ColorConstant.title,
                  fontSize: SizeConstant.h7,
                ),
              ),
              SizedBox(
                width: 10.w,
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: ColorConstant.title,
                size: 32.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("设置"),
      content: ListView(
        children: [
          buildItem(
            $t('转账'),
            '',
            () {
              if (LoginDialog.shouldShow(context)) {
                return;
              }
              BottomDialog.showDialog(context, TransferDialog());
            },
          ),
          buildItem(
            $t('备份私钥'),
            '',
            () {
              showPrivateKey();
            },
          ),
          buildItem(
            $t('Telegram'),
            '',
            () {
              launch('https://t.me/NWLD_CN');
            },
          ),
          buildItem(
            $t('Btok 币用'),
            '',
            () {
              launch('https://0.plus/NWLD_CN');
            },
          ),
          buildItem(
            $t('QQ群'),
            '103682866',
            () {
              ClipboardData data = new ClipboardData(
                text: '103682866',
              );
              Clipboard.setData(data);
              ToastUtil.showToast(
                $t("已复制"),
                type: ToastType.success,
              );
            },
          ),
          buildItem(
            'Version',
            ver,
            () {},
          ),
          TouchDownScale(
            onTap: () {
              BaseDialogContainer.showDialog(
                context: context,
                child: CenterDialogContainer(
                  title: $t('退出账号'),
                  content: $t('危险操作，请先备份私钥再退出，否则资产会永远消失！！！'),
                  cancel: $t('取消'),
                  confirm: $t('退出'),
                  onConfirm: () {
                    AccountModel.getInstance().exit();
                  },
                ),
              );
            },
            child: ShadowContainer(
              margin: EdgeInsets.only(
                  left: 40.w, right: 40.w, bottom: 40.w, top: 60.w),
              padding: EdgeInsets.only(left: 20.w, right: 20.w),
              height: 96.w,
              color: ColorConstant.title,
              child: Center(
                child: Text(
                  '退出账号，请先备份私钥',
                  style: TextStyle(
                    color: ColorConstant.bg_level_9,
                    fontSize: SizeConstant.h7,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
