import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/toast_util.dart';
import '../../widgets/touch_down_scale.dart';
import 'bottom_dialog_container.dart';

class ShopItem extends StatelessWidget {
  final int index;
  final bool disabled;
  final Function onBuy;

  ShopItem({
    this.index,
    this.disabled = false,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final $t = create$t(context);
    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 20.w),
      child: Container(
        height: 200.w,
        child: Column(
          children: <Widget>[
            Container(
              height: 180.w,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/game/bg_list_store.png",
                  ),
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 5.w,
                    top: 5.w,
                    child: Container(
                      width: 48.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/game/bg_grade_list.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 5.w,
                          right: 5.w,
                          top: 8.w,
                        ),
                        child: Text(
                          'TODO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConstant.h9,
                            fontFamily: "Facon",
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16.w,
                    top: 26.w,
                    child: Container(),
                  ),
                  Positioned(
                    right: 0.w,
                    top: 0.w,
                    child: Container(
                      width: 306.w,
                      height: 60.w,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/game/bg_text.png"),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Text(
                        disabled ? $t('待解锁') : "倒计时",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: SizeConstant.h8,
                            fontFamily: "CarterOne-Regular"),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 32.w,
                    bottom: 20.w,
                    child: TouchDownScale(
                      onTapDown: (ev) {
                        if (!disabled) {}
                      },
                      onTap: () {
                        if (!disabled) {}
                      },
                      child: Container(
                        width: 240.w,
                        height: 92.w,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(disabled
                                ? "assets/game/button_gray.png"
                                : "assets/game/button_red.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                disabled
                                    ? 'assets/game/ic_lock.png'
                                    : 'assets/game/ic_coin.png',
                                width: 36.w,
                                height: 36.w,
                              ),
                              SizedBox(width: 5),
                              if (!disabled)
                                Text(
                                  '测试',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConstant.h5,
                                    fontFamily: "CarterOne-Regular",
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.w)
          ],
        ),
      ),
    );
  }
}

class ShopDialog extends StatefulWidget {
  @override
  _ShopDialogState createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog>
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
        title: $t("商店"),
        backgroundImagePath: "assets/game/bg_store.png",
        content: ListView.builder(
          controller: _controller,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ShopItem(
              index: index,
              disabled: false,
              onBuy: (int index) {
                bool success = true;
                if (success) {
                  ToastUtil.showToast($t("购买成功"), type: ToastType.success);
                }
              },
            );
          },
        ),
      );
    });
  }
}
