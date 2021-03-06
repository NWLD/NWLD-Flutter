import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/entity/TalkingData.dart';
import 'package:kingspro/entity/TransactionInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/transaction_confirm_dialog.dart';
import 'package:kingspro/service/TalkingRoomService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import 'bottom_dialog_container.dart';

class TalkingItem extends StatefulWidget {
  final int index;
  final TalkingData talkingData;

  TalkingItem({
    this.index,
    this.talkingData,
  });

  @override
  _TalkingItemState createState() {
    return _TalkingItemState();
  }
}

class _TalkingItemState extends State<TalkingItem>
    with BaseLocalizationsStateMixin {
  TalkingData talkingData;

  @override
  void initState() {
    talkingData = widget.talkingData;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
      child: Column(
        crossAxisAlignment: AccountModel().account != null &&
                AccountModel().account.toLowerCase() ==
                    talkingData.address.toLowerCase()
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: AccountModel().account != null &&
                    AccountModel().account.toLowerCase() ==
                        talkingData.address.toLowerCase()
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Text(
                StringUtils.isEmpty(talkingData.nick)
                    ? StringUtils.simpleAccount(talkingData.address)
                    : talkingData.nick,
                style: TextStyle(
                  color: ColorConstant.title,
                  fontSize: SizeConstant.h9,
                ),
              )
            ],
          ),
          SizedBox(
            height: 10.w,
          ),
          ShadowContainer(
            padding: EdgeInsets.all(20.w),
            color: AccountModel().account != null &&
                    AccountModel().account.toLowerCase() ==
                        talkingData.address.toLowerCase()
                ? ColorConstant.titleBg
                : ColorConstant.bg_level_2,
            child: Text(
              talkingData.msg,
              style: TextStyle(
                color: ColorConstant.bg_level_9,
                fontSize: SizeConstant.h8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TalkingDialog extends StatefulWidget {
  @override
  _TalkingDialogState createState() => _TalkingDialogState();
}

class _TalkingDialogState extends State<TalkingDialog>
    with BaseLocalizationsStateMixin {
  List<TalkingData> _list = <TalkingData>[];
  BigInt lastIndex = BigInt.from(0);

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );
  TextEditingController editingController;

  @override
  void initState() {
    getTalkingList();
    editingController = new TextEditingController();
    super.initState();
  }

  PeriodicTimer _periodicTimer;

  void getTalkingList() {
    if (null != _periodicTimer) {
      return;
    }
    _periodicTimer = PeriodicTimer();
    _periodicTimer.start(
      milliseconds: 6000,
      maxCount: 1000000,
      firstAction: true,
      action: () async {
        try {
          TalkingDataList talkingDataList =
              await TalkingRoomService.getTalkingDataList(lastIndex);
          if (null == _periodicTimer) {
            return;
          }
          lastIndex = talkingDataList.lastIndex;
          _list.addAll(talkingDataList.list);
          setState(() {});
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        }
      },
      onEnd: (max) {},
    );
  }

  @override
  dispose() {
    _periodicTimer.cancel(false);
    _periodicTimer = null;
    _controller.dispose();
    super.dispose();
  }

  Widget buildTextField({
    TextEditingController editingController,
    double height,
    String hint,
    int maxLines,
  }) {
    return Container(
      alignment: Alignment.centerLeft,
      constraints: BoxConstraints(minHeight: height),
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFFFDFFFF),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: ColorConstant.des),
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
          fontSize: SizeConstant.h8,
          height: 1,
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

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("?????????"),
      content: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _controller,
              itemCount: _list.length,
              itemBuilder: (context, index) {
                return TalkingItem(
                  index: index,
                  talkingData: _list[index],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
                top: 20.w, bottom: 20.w, left: 40.w, right: 40.w),
            child: Row(
              children: [
                Expanded(
                  child: buildTextField(
                    editingController: editingController,
                    maxLines: 3,
                    height: 80.w,
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                TouchDownScale(
                  onTap: () async {
                    if (LoginDialog.shouldShow(context)) {
                      return;
                    }
                    if (StringUtils.isEmpty(editingController.text)) {
                      return;
                    }
                    try {
                      Transaction transaction =
                          await TalkingRoomService.sendMsg(
                              editingController.text);
                      TransactionInfo transactionInfo = TransactionInfo(
                        transaction,
                        '0 ' +
                            SettingsModel.getInstance().currentChain().symbol,
                      );
                      String hash = await TransactionConfirmDialog.send(
                          context, transactionInfo);
                      if (StringUtils.isEmpty(hash)) {
                        return;
                      }
                      setState(() {
                        editingController.text = '';
                      });
                    } catch (e) {
                      ToastUtil.showToast(e.toString(), type: ToastType.error);
                    }
                  },
                  child: ShadowContainer(
                      width: 100.w,
                      height: 80.w,
                      color: ColorConstant.titleBg,
                      child: Center(
                        child: Text(
                          $t('??????'),
                          style: TextStyle(
                            color: ColorConstant.title,
                            fontSize: SizeConstant.h8,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
