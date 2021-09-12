import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/TokenShopItem.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/service/TokenShopService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/touch_down_scale.dart';
import 'bottom_dialog_container.dart';

class TokenShopItemWidget extends StatefulWidget {
  final int index;

  TokenShopItemWidget({
    this.index,
  });

  @override
  State<TokenShopItemWidget> createState() {
    return _ShopItemState();
  }
}

class _ShopItemState extends State<TokenShopItemWidget>
    with BaseLocalizationsStateMixin {
  TokenShopItem _shopItem;

  @override
  void initState() {
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
        TokenShopItem shopItem = await TokenShopService.getInfo(widget.index);
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

  void buyToken() async {
    try {
      EasyLoading.show(dismissOnTap: true);
      String buyHash =
          await TokenShopService.buy(_shopItem.price, widget.index);
      confirmBuy(buyHash);
    } catch (e) {
      ToastUtil.showToast(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
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
            ToastUtil.showToast($t('购买失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            _buyPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('购买成功'), type: ToastType.success);
          }
        } catch (e) {
          LogUtil.log('confirmBuy', e);
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

  Widget buildBuyButton() {
    //已买过
    if (_shopItem.bought) {
      return Text(
        _shopItem.price == BigInt.from(0) ? $t('已领过') : $t('已买过'),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConstant.h8,
        ),
      );
    }
    //已卖光
    if (_shopItem.soldCount >= _shopItem.qty) {
      return Text(
        _shopItem.price == BigInt.from(0) ? $t('已领完') : $t('已售罄'),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConstant.h8,
        ),
      );
    }
    return TouchDownScale(
      onTapDown: (ev) {},
      onTap: () {
        buyToken();
      },
      child: ShadowContainer(
        width: 100.w,
        height: 50.w,
        color: ColorConstant.bg_level_9,
        child: Center(
          child: Text(
            _shopItem.price == BigInt.from(0) ? $t('领取') : $t('购买'),
            style: TextStyle(
              color: ColorConstant.title,
              fontSize: SizeConstant.h8,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == _shopItem) {
      return Container();
    }
    return ShadowContainer(
      height: 200.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.all(20.w),
      color: ColorConstant.titleBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            NumberUtil.decimalNumString(
                    num: _shopItem.amount.toString(), fractionDigits: 0) +
                ' ' +
                ConfigConstants.gameTokenSymbol,
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h7,
            ),
          ),
          SizedBox(height: 16.w),
          Text(
            NumberUtil.decimalNumString(
                  num: _shopItem.price.toString(),
                  fractionDigits: 4,
                ) +
                ' ' +
                SettingsModel.getInstance().currentChain().symbol,
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h7,
            ),
          ),
          Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_shopItem.soldCount}/${_shopItem.qty}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConstant.h7,
                ),
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
    super.dispose();
  }
}

class TokenShopDialog extends StatefulWidget {
  @override
  _ShopDialogState createState() => _ShopDialogState();
}

class _ShopDialogState extends State<TokenShopDialog>
    with BaseLocalizationsStateMixin {
  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    super.initState();
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
        title: $t("礼包"),
        content: ListView.builder(
          controller: _controller,
          itemCount: 4,
          itemBuilder: (context, index) {
            return TokenShopItemWidget(
              index: index + 1,
            );
          },
        ),
      );
    });
  }
}
