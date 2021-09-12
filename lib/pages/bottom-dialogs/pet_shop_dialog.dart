import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/entity/PetShopInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/open_card_dialog.dart';
import 'package:kingspro/service/PetService.dart';
import 'package:kingspro/service/PetShopService.dart';
import 'package:kingspro/service/TokenService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/TimerView.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/touch_down_scale.dart';
import 'bottom_dialog_container.dart';

class PetShopItemWidget extends StatefulWidget {
  @override
  State<PetShopItemWidget> createState() {
    return _ShopItemState();
  }
}

class _ShopItemState extends State<PetShopItemWidget>
    with BaseLocalizationsStateMixin {
  PetShopInfo _shopItem;
  BigInt _allowance;

  @override
  void initState() {
    getAllowance();
    updateSaleInfo();
    super.initState();
  }

  void updateSaleInfo() {
    if (null != _infoPeriodicTimer) {
      return;
    }
    _infoPeriodicTimer = PeriodicTimer();
    _infoPeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      firstAction: true,
      action: () async {
        try {
          PetShopInfo shopItem = await PetShopService.getInfo();
          if (null == _infoPeriodicTimer) {
            return;
          }
          setState(() {
            _shopItem = shopItem;
          });
          //已卖光
          if (shopItem.soldCount >= shopItem.qty) {
            _infoPeriodicTimer.cancel(false);
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        _cancelInfoPeriodicTimer();
      },
    );
  }

  PeriodicTimer _infoPeriodicTimer;

  void _cancelInfoPeriodicTimer() {
    if (null != _infoPeriodicTimer) {
      _infoPeriodicTimer.cancel(false);
      _infoPeriodicTimer = null;
    }
  }

  void getAllowance() async {
    if (StringUtils.isEmpty(AccountModel.getInstance().account)) {
      return;
    }
    BigInt allowance = await TokenService.allowance(
      ConfigModel.getInstance().config(ConfigConstants.petShop),
    );
    setState(() {
      _allowance = allowance;
    });
  }

  void approve() async {
    if (LoginDialog.shouldShow(context)) {
      return;
    }
    try {
      EasyLoading.show(dismissOnTap: true);
      String hash = await TokenService.approve(
        ConfigModel.getInstance().config(ConfigConstants.petShop),
        NumberUtil.pow(num: '1000', exponent: 26),
      );
      confirmApprove(hash);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    } finally {
      EasyLoading.dismiss();
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

  buy(int num) async {
    //余额
    BigInt gameTokenBalance = AccountModel().gameTokenBalance;
    print('We have $gameTokenBalance Token');
    //余额不足
    if (null == gameTokenBalance ||
        gameTokenBalance < _shopItem.price * BigInt.from(num)) {
      ToastUtil.showToast(
        $t('余额不足'),
        type: ToastType.warning,
      );
      return;
    }
    try {
      EasyLoading.show(dismissOnTap: true);
      String buyHash = await PetShopService.buy(num);
      confirmBuy(buyHash, num);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  PeriodicTimer _buyPeriodicTimer;

  void confirmBuy(String hash, int num) async {
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
            ToastUtil.showToast($t('购买失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _buyPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('购买成功'), type: ToastType.success);
            showOpenCardDialog(num);
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

  void showOpenCardDialog(int num) async {
    try {
      List<PetInfo> pets =
          await PetService.getPets(AccountModel.getInstance().account);
      int len = pets.length;
      //只显示最近购买的
      int index = len - num;
      if (index < 0) {
        index = 0;
      }
      List<PetInfo> numPets = [];
      for (; index < len; index++) {
        numPets.add(pets[index]);
      }
      BottomDialog.showDialog(
        context,
        OpenCardDialog(
          pets: numPets,
        ),
      );
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  void _cancelBuyPeriodicTimer() {
    if (null != _buyPeriodicTimer) {
      _buyPeriodicTimer.cancel(false);
      _buyPeriodicTimer = null;
    }
  }

  Widget buildBuyButton() {
    int seconds = _shopItem.startTime - _shopItem.nowTime;
    //未开始
    if (seconds > 0) {
      return TimerView(
        color: Colors.white,
        initSeconds: seconds,
        onCountdownEnd: () {
          setState(() {});
          updateSaleInfo();
        },
      );
    }
    //已卖光
    if (_shopItem.soldCount >= _shopItem.qty) {
      return Text(
        $t('已卖光'),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConstant.h8,
        ),
      );
    }
    //授权
    if (null == _allowance || _allowance < _shopItem.price * BigInt.from(10)) {
      return TouchDownScale(
        onTapDown: (ev) {},
        onTap: () {
          approve();
        },
        child: ShadowContainer(
          width: 100.w,
          height: 48.w,
          color: ColorConstant.bg_level_9,
          child: Center(
            child: Text(
              $t('授权'),
              style: TextStyle(
                color: ColorConstant.title,
                fontSize: SizeConstant.h8,
              ),
            ),
          ),
        ),
      );
    }
    return Row(
      children: [
        TouchDownScale(
          onTapDown: (ev) {},
          onTap: () {
            buy(1);
          },
          child: ShadowContainer(
            width: 100.w,
            height: 48.w,
            color: ColorConstant.bg_level_4,
            child: Center(
              child: Text(
                $t('购买'),
                style: TextStyle(
                  color: ColorConstant.title,
                  fontSize: SizeConstant.h9,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.w,
        ),
        TouchDownScale(
          onTapDown: (ev) {},
          onTap: () {
            buy(10);
          },
          child: ShadowContainer(
            width: 100.w,
            height: 48.w,
            color: ColorConstant.bg_level_9,
            child: Center(
              child: Text(
                $t('10 连'),
                style: TextStyle(
                  color: ColorConstant.title,
                  fontSize: SizeConstant.h8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == _shopItem) {
      return Container();
    }
    return ShadowContainer(
      height: 320.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.all(20.w),
      color: ColorConstant.titleBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _shopItem.title,
            style: TextStyle(
                color: Colors.white,
                fontSize: SizeConstant.h7,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.w),
          Text(
            _shopItem.des,
            style: TextStyle(
              color: ColorConstant.title,
              fontSize: SizeConstant.h9,
            ),
          ),
          Expanded(child: Container()),
          Text(
            NumberUtil.decimalNumString(
                  num: _shopItem.price.toString(),
                  fractionDigits: 0,
                ) +
                ' ' +
                ConfigConstants.gameTokenSymbol,
            style: TextStyle(
                color: Colors.white,
                fontSize: SizeConstant.h7,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.w),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_shopItem.soldCount}/${_shopItem.qty}',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h7,
                    fontWeight: FontWeight.bold),
              ),
              Expanded(child: Container()),
              buildBuyButton(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cancelInfoPeriodicTimer();
    _cancelBuyPeriodicTimer();
    _cancelApprovePeriodicTimer();
    super.dispose();
  }
}

class PetShopDialog extends StatefulWidget {
  @override
  _PetShopDialogState createState() => _PetShopDialogState();
}

class _PetShopDialogState extends State<PetShopDialog>
    with BaseLocalizationsStateMixin {
  List shopAddressList = <String>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getItems();
    super.initState();
  }

  void getItems() async {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        shopAddressList = [
          ConfigModel.getInstance().config(ConfigConstants.petShop),
        ];
      });
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(builder: (context, accountModel, child) {
      return BottomDialogContainer(
        title: $t("卡包"),
        content: Column(
          children: [
            PetShopItemWidget(),
          ],
        ),
      );
    });
  }
}
