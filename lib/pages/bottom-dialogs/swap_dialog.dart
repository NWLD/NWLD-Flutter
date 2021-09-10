import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenPoolInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/service/TokenPoolService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/touch_down_scale.dart';
import 'bottom_dialog_container.dart';

class SwapDialog extends StatefulWidget {
  @override
  _SwapDialogState createState() => _SwapDialogState();
}

class _SwapDialogState extends State<SwapDialog>
    with BaseLocalizationsStateMixin {
  TokenPoolInfo tokenPoolInfo;
  TextEditingController buyEditingController;
  TextEditingController sellEditingController;
  String buyAmount;
  String sellAmount;

  @override
  void initState() {
    buyEditingController = TextEditingController();
    buyEditingController.addListener(() {
      setState(() {
        buyAmount = '';
      });
      estimateBuy();
    });
    sellEditingController = TextEditingController();
    getInfo();
    super.initState();
  }

  PeriodicTimer _infoPeriodicTimer;

  void getInfo() {
    if (null != _infoPeriodicTimer) {
      return;
    }
    _infoPeriodicTimer = PeriodicTimer();
    _infoPeriodicTimer.start(
      milliseconds: 6000,
      maxCount: 100000,
      firstAction: true,
      action: () async {
        TokenPoolInfo info = await TokenPoolService.getInfo();
        if (null != _infoPeriodicTimer) {
          setState(() {
            tokenPoolInfo = info;
          });
        }
      },
      onEnd: (max) {},
    );
  }

  PeriodicTimer _estimateBuyPeriodicTimer;

  void estimateBuy() {
    if (null != _estimateBuyPeriodicTimer) {
      return;
    }
    _estimateBuyPeriodicTimer = PeriodicTimer();
    _estimateBuyPeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      firstAction: true,
      action: () async {
        String input = buyEditingController.text.trim();
        if (StringUtils.isEmpty(input)) {
          setState(() {
            buyAmount = '';
          });
          return;
        }
        BigInt estimateBuyAmount = await TokenPoolService.estimateBuy(input);
        if (null == _estimateBuyPeriodicTimer) {
          return;
        }
        if (input == buyEditingController.text.trim()) {
          setState(() {
            buyAmount = NumberUtil.decimalNumString(
                num: estimateBuyAmount.toString(), fractionDigits: 0);
          });
        }
      },
      onEnd: (max) {},
    );
  }

  @override
  dispose() {
    if (null != _infoPeriodicTimer) {
      _infoPeriodicTimer.cancel(false);
      _infoPeriodicTimer = null;
    }
    if (null != _estimateBuyPeriodicTimer) {
      _estimateBuyPeriodicTimer.cancel(false);
      _estimateBuyPeriodicTimer = null;
    }
    super.dispose();
  }

  buildText(String text, [EdgeInsetsGeometry padding]) {
    return Padding(
      padding:
          padding ?? EdgeInsets.only(left: 40.w, right: 40.w, bottom: 20.w),
      child: AutoFontSizeText(
        text: text,
        minfontSize: 10,
        style: TextStyle(
          color: ColorConstant.title,
          fontSize: SizeConstant.h8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
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
        keyboardType: TextInputType.numberWithOptions(decimal: true),
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

  Widget buildBuyField() {
    return buildTextField(
      editingController: buyEditingController,
      height: 80.w,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(builder: (context, accountModel, child) {
      return BottomDialogContainer(
        title: $t("兑换"),
        content: null == tokenPoolInfo
            ? Container()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildText($t("池子信息")),
                  buildText(
                    NumberUtil.decimalNumString(
                          num: tokenPoolInfo.tokenBalance.toString(),
                          fractionDigits: 0,
                        ) +
                        ' ' +
                        ConfigConstants.gameTokenSymbol +
                        " : " +
                        NumberUtil.decimalNumString(
                          num: tokenPoolInfo.ethBalance.toString(),
                          fractionDigits: 4,
                        ) +
                        ' ' +
                        SettingsModel.getInstance().currentChain().symbol,
                  ),
                  buildText(
                    '1 ' +
                        ConfigConstants.gameTokenSymbol +
                        ' = ' +
                        NumberUtil.decimalNumString(
                          num: tokenPoolInfo.tokenPrice.toString(),
                          fractionDigits: 18,
                        ) +
                        ' ' +
                        SettingsModel.getInstance().currentChain().symbol,
                  ),
                  //购买
                  Padding(
                    padding: EdgeInsets.only(left: 40.w, right: 40.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: buildBuyField(),
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        buildText(
                            SettingsModel.getInstance().currentChain().symbol,
                            EdgeInsets.all(0)),
                        SizedBox(
                          width: 10.w,
                        ),
                        TouchDownScale(
                          child: ShadowContainer(
                            width: 100.w,
                            height: 60.w,
                            color: ColorConstant.titleBg,
                            child: Center(
                              child: Text(
                                $t('购买'),
                                style: TextStyle(
                                  color: ColorConstant.title,
                                  fontSize: SizeConstant.h7,
                                ),
                              ),
                            ),
                          ),
                          onTap: () async {
                            if (StringUtils.isEmpty(buyAmount)) {
                              return;
                            }
                            EasyLoading.show(dismissOnTap: true);
                            //内置1%的滑点
                            try {
                              TokenPoolService.buy(
                                  buyEditingController.text.trim(),
                                  (BigInt.parse(buyAmount) *
                                          BigInt.from(99) /
                                          BigInt.from(100))
                                      .toString());
                            } catch (e) {} finally {
                              EasyLoading.dismiss();
                            }
                          },
                        ),
                        SizedBox(
                          width: 10.w,
                        ),
                        Expanded(
                          child: buildText(buyAmount ?? "", EdgeInsets.all(0)),
                        ),
                        buildText(
                            ConfigConstants.gameTokenSymbol, EdgeInsets.all(0)),
                      ],
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
