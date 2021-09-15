import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenPoolInfo.dart';
import 'package:kingspro/entity/TransactionInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/transaction_confirm_dialog.dart';
import 'package:kingspro/service/TokenPoolService.dart';
import 'package:kingspro/service/TokenService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/base_button.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
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
  BigInt _allowance;

  @override
  void initState() {
    buyEditingController = TextEditingController();
    buyEditingController.addListener(() {
      setBuyAmount();
    });
    sellEditingController = TextEditingController();
    sellEditingController.addListener(() {
      setSellAmount();
    });
    getInfo();
    getAllowance();
    super.initState();
  }

  void setSellAmount() {
    if (null == tokenPoolInfo ||
        BigInt.from(0) == tokenPoolInfo.sellPrice ||
        StringUtils.isEmpty(sellEditingController.text)) {
      setState(() {
        sellAmount = '';
      });
      return;
    }
    setState(() {
      String num =
          (NumberUtil.pow(num: sellEditingController.text.trim(), exponent: 1) *
                  tokenPoolInfo.sellPrice)
              .toString();
      sellAmount = NumberUtil.decimalNumString(num: num, fractionDigits: 6);
    });
  }

  void setBuyAmount() {
    if (null == tokenPoolInfo ||
        BigInt.from(0) == tokenPoolInfo.buyPrice ||
        StringUtils.isEmpty(buyEditingController.text)) {
      setState(() {
        buyAmount = '';
      });
      return;
    }
    setState(() {
      String num =
          (NumberUtil.pow(num: buyEditingController.text.trim(), exponent: 36) /
                  tokenPoolInfo.buyPrice)
              .toString();
      buyAmount = NumberUtil.decimalNumString(num: num, fractionDigits: 0);
    });
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
          setSellAmount();
          setBuyAmount();
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
    _cancelBuyPeriodicTimer();
    _cancelSellPeriodicTimer();
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

  Widget buildInfo() {
    return Row(
      children: [
        Expanded(
          child: Consumer<AccountModel>(builder: (
            BuildContext context,
            AccountModel accountModel,
            Widget child,
          ) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText($t("个人资产")),
                buildText(NumberUtil.decimalNumString(
                      num: accountModel.gameTokenBalance.toString(),
                      fractionDigits: 0,
                    ) +
                    ' ' +
                    ConfigConstants.gameTokenSymbol),
                buildText(
                  NumberUtil.decimalNumString(
                        num: accountModel.balance.toString(),
                        fractionDigits: 6,
                      ) +
                      ' ' +
                      SettingsModel.getInstance().currentChain().symbol,
                ),
              ],
            );
          }),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildText($t("池子资产")),
              buildText(NumberUtil.decimalNumString(
                    num: tokenPoolInfo.tokenBalance.toString(),
                    fractionDigits: 0,
                  ) +
                  ' ' +
                  ConfigConstants.gameTokenSymbol),
              buildText(
                NumberUtil.decimalNumString(
                      num: tokenPoolInfo.ethBalance.toString(),
                      fractionDigits: 6,
                    ) +
                    ' ' +
                    SettingsModel.getInstance().currentChain().symbol,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBuyField() {
    return buildTextField(
      editingController: buyEditingController,
      height: 80.w,
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
            ToastUtil.showToast($t('买入失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _buyPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('买入成功'), type: ToastType.success);
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

  Widget buildBuyBoard() {
    return Expanded(
      child: ShadowContainer(
        color: ColorConstant.titleBg,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(
              $t('价格') +
                  ': ' +
                  NumberUtil.decimalNumString(
                    num: tokenPoolInfo.buyPrice.toString(),
                    fractionDigits: 18,
                  ),
              EdgeInsets.all(0),
            ),
            SizedBox(
              height: 10.w,
            ),
            Row(
              children: [
                Expanded(
                  child: buildBuyField(),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  width: 80.w,
                  child: buildText(
                    SettingsModel.getInstance().currentChain().symbol,
                    EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.w,
            ),
            Row(
              children: [
                Expanded(
                  child: ShadowContainer(
                    height: 80.w,
                    color: Colors.transparent,
                    padding: EdgeInsets.all(10.w),
                    child: Container(
                      alignment: AlignmentDirectional.centerStart,
                      child: buildText(buyAmount ?? "", EdgeInsets.all(0)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  width: 80.w,
                  child: buildText(
                    ConfigConstants.gameTokenSymbol,
                    EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.w,
            ),
            BaseButton(
              onTap: () async {
                if (StringUtils.isEmpty(buyAmount)) {
                  return;
                }
                try {
                  Transaction transaction = await TokenPoolService.buy(
                    buyEditingController.text.trim(),
                  );
                  TransactionInfo transactionInfo = TransactionInfo(
                    transaction,
                    buyEditingController.text.trim() +
                        ' ' +
                        SettingsModel.getInstance().currentChain().symbol,
                  );
                  String hash = await TransactionConfirmDialog.send(
                      context, transactionInfo);
                  if (StringUtils.isEmpty(hash)) {
                    return;
                  }
                  setState(() {
                    buyEditingController.text = '';
                  });
                  confirmBuy(hash);
                } catch (e) {
                  ToastUtil.showToast(e.toString(), type: ToastType.error);
                }
              },
              title: $t('买入'),
              width: 100.w,
              height: 60.w,
              bg: ColorConstant.bg_level_9,
              color: ColorConstant.title,
              fontSize: SizeConstant.h8,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSellField() {
    return buildTextField(
      editingController: sellEditingController,
      height: 80.w,
    );
  }

  void getAllowance() async {
    if (StringUtils.isEmpty(AccountModel.getInstance().account)) {
      return;
    }
    BigInt allowance = await TokenService.allowance(
      ConfigModel.getInstance().config(ConfigConstants.tokenPool),
    );
    setState(() {
      _allowance = allowance;
    });
  }

  void approve() async {
    try {
      Transaction transaction = await TokenService.approve(
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
        NumberUtil.pow(num: '1000', exponent: 26),
      );
      TransactionInfo transactionInfo = TransactionInfo(
        transaction,
        $t('授权 ') +
            NumberUtil.decimalNumString(
              num: NumberUtil.pow(num: '1000', exponent: 26).toString(),
            ) +
            ' ' +
            ConfigConstants.gameTokenSymbol,
        ConfigModel.getInstance().config(ConfigConstants.tokenPool),
      );
      String hash =
          await TransactionConfirmDialog.send(context, transactionInfo);
      if (StringUtils.isEmpty(hash)) {
        return;
      }
      confirmApprove(hash);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  PeriodicTimer _approvePeriodicTimer;

  void confirmApprove(String hash) async {
    EasyLoading.show(dismissOnTap: true);
    if (null != _approvePeriodicTimer) {
      return;
    }
    _approvePeriodicTimer = PeriodicTimer();
    _approvePeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _approvePeriodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _approvePeriodicTimer.cancel(false);
            ToastUtil.showToast($t('授权失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _approvePeriodicTimer.cancel(false);
            setState(() {
              _allowance = NumberUtil.pow(num: '1000', exponent: 26);
            });
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        EasyLoading.dismiss();
        _cancelApprovePeriodicTimer();
      },
    );
  }

  void _cancelApprovePeriodicTimer() {
    if (null != _approvePeriodicTimer) {
      _approvePeriodicTimer.cancel(false);
      _approvePeriodicTimer = null;
    }
  }

  PeriodicTimer _sellPeriodicTimer;

  void confirmSell(String hash) async {
    EasyLoading.show(dismissOnTap: true);
    if (null != _sellPeriodicTimer) {
      return;
    }
    _sellPeriodicTimer = PeriodicTimer();
    _sellPeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _sellPeriodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _sellPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('卖出失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _sellPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('卖出成功'), type: ToastType.success);
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

  void _cancelSellPeriodicTimer() {
    if (null != _sellPeriodicTimer) {
      _sellPeriodicTimer.cancel(false);
      _sellPeriodicTimer = null;
    }
  }

  Widget buildSellBoard() {
    return Expanded(
      child: ShadowContainer(
        color: ColorConstant.bg_level_9,
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText(
              $t('价格') +
                  ': ' +
                  NumberUtil.decimalNumString(
                    num: tokenPoolInfo.sellPrice.toString(),
                    fractionDigits: 18,
                  ),
              EdgeInsets.all(0),
            ),
            SizedBox(
              height: 10.w,
            ),
            Row(
              children: [
                Expanded(
                  child: buildSellField(),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  width: 80.w,
                  child: buildText(
                    ConfigConstants.gameTokenSymbol,
                    EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.w,
            ),
            Row(
              children: [
                Expanded(
                  child: ShadowContainer(
                    height: 80.w,
                    color: Colors.transparent,
                    padding: EdgeInsets.all(10.w),
                    child: Container(
                      alignment: AlignmentDirectional.centerStart,
                      child: buildText(sellAmount ?? "", EdgeInsets.all(0)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10.w,
                ),
                Container(
                  width: 80.w,
                  child: buildText(
                    SettingsModel.getInstance().currentChain().symbol,
                    EdgeInsets.all(0),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20.w,
            ),
            Row(
              children: [
                Expanded(child: Container()),
                buildSellButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSellButton() {
    if (null == _allowance ||
        AccountModel.getInstance().gameTokenBalance > _allowance) {
      return BaseButton(
        onTap: approve,
        title: $t('授权'),
        width: 100.w,
        height: 60.w,
        bg: ColorConstant.titleBg,
        color: ColorConstant.title,
        fontSize: SizeConstant.h8,
      );
    }
    return BaseButton(
      onTap: () async {
        if (StringUtils.isEmpty(sellAmount)) {
          return;
        }
        try {
          Transaction transaction = await TokenPoolService.sell(
            sellEditingController.text.trim(),
          );
          TransactionInfo transactionInfo = TransactionInfo(
            transaction,
            sellEditingController.text.trim() +
                ' ' +
                ConfigConstants.gameTokenSymbol,
          );
          String hash =
              await TransactionConfirmDialog.send(context, transactionInfo);
          if (StringUtils.isEmpty(hash)) {
            return;
          }
          setState(() {
            sellEditingController.text = '';
          });
          confirmSell(hash);
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        }
      },
      title: $t('卖出'),
      width: 100.w,
      height: 60.w,
      bg: ColorConstant.titleBg,
      color: ColorConstant.title,
      fontSize: SizeConstant.h8,
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  buildInfo(),
                  Padding(
                    padding: EdgeInsets.only(left: 20.w, right: 20.w),
                    child: Row(
                      children: [
                        buildBuyBoard(),
                        SizedBox(
                          width: 20.w,
                        ),
                        buildSellBoard(),
                      ],
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
