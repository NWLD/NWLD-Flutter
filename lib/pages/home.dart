import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../routes/routes.dart';
import '../../widgets/beautify_avatar.dart';
import '../anim/car_path_anim.dart';
import '../widgets/touch_down_scale.dart';

class GeneralHomeButton extends StatelessWidget {
  final String text;
  final String image;
  final num width;
  final num height;
  final Function onTap;
  final EdgeInsets padding;
  final double fontSize;

  GeneralHomeButton({
    this.text = '',
    this.image,
    this.width,
    this.height,
    this.onTap,
    this.padding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: onTap,
      onTapDown: (ev) {},
      child: Container(
        width: width,
        height: height ?? 130.w,
        alignment: Alignment.bottomCenter,
        padding:
            padding ?? EdgeInsets.only(bottom: 22.w, left: 20.w, right: 20.w),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: Container(
          height: 32.w,
          alignment: Alignment.center,
          child: AutoSizeText(
            text,
            textAlign: TextAlign.center,
            maxLines: 1,
            minFontSize: 1,
            style: TextStyle(
              fontSize: fontSize ?? SizeConstant.h8,
              fontFamily: "CarterOne-Regular",
              height: 1,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class GameHomePage extends StatefulWidget {
  @override
  _GameHomePageState createState() => _GameHomePageState();
}

class _GameHomePageState extends State<GameHomePage>
    with BaseLocalizationsStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive: // 处于这种状态的应用程序应该假设它们可能在任何时候暂停。
        break;
      case AppLifecycleState.resumed: // 应用程序可见，前台
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  showShop() {
    // BottomDialog.showDialog(context, ShopDialog());
  }

  showRank() {
    // BottomDialog.showDialog(context, RankDialog());
  }

  showPersonalCenter() {
    // BottomDialog.showDialog(context, MineDialog());
  }

  buildAvatar() {
    return Consumer<AccountModel>(builder: (context, accountModel, child) {
      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          Positioned(
            left: 0.w,
            width: 344.w,
            height: 80.w,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  alignment: Alignment.centerRight,
                  image: AssetImage('assets/game/bg_wallet_balance.png'),
                ),
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTapDown: (ev) {},
                onTap: showPersonalCenter,
                child: BeautifyAvatar(
                  avatar: '',
                ),
              ),
              SizedBox(width: 10.w),
              GestureDetector(
                onTapDown: (ev) {},
                onTap: () {},
                child: Column(
                  children: [
                    Container(
                      width: 180.w,
                      child: AutoSizeText(
                        'TODO HT',
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: SizeConstant.h8,
                          fontWeight: FontWeight.bold,
                          fontFamily: "CarterOne-Regular",
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4.w,
                    ),
                    Container(
                      width: 180.w,
                      child: AutoSizeText(
                        'TODO HT',
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: SizeConstant.h10,
                          fontFamily: "CarterOne-Regular",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  buildTopButtons() {
    return Column(
      children: [
        SizedBox(height: 10.w),
        Row(
          children: [
            Expanded(
              child: buildAvatar(),
              flex: 1,
            ),
            buildStoreButton(),
          ],
        )
      ],
    );
  }

  buildInviteButton() {
    return GeneralHomeButton(
      text: $t('资产'),
      image: 'assets/game/button_invite.png',
      width: 220.w,
      onTap: () {
        Navigator.pushNamed(context, RouteMap.team);
      },
    );
  }

  buildStoreButton() {
    return GeneralHomeButton(
      text: $t('交易市场'),
      image: 'assets/game/button_store.png',
      width: 220.w,
      onTap: showShop,
    );
  }

  buildBottomButtons() {
    return Consumer<AccountModel>(
      builder: (context, accountModel, child) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SizedBox(height: 400.w), // 撑开底部按钮空间
            Row(
              crossAxisAlignment: CrossAxisAlignment.end, //横轴居中对齐(默认)
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    child: GeneralHomeButton(
                      text: $t('礼包'),
                      image: 'assets/game/button_luckydraw.png',
                      width: 150.w,
                      onTap: () {},
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    child: buildInviteButton(),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: AlignmentDirectional.center,
                    child: GeneralHomeButton(
                      text: $t('排行榜'),
                      image: 'assets/game/button_rank.png',
                      width: 150.w,
                      onTap: showRank,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    EdgeInsets padding = data.padding;
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              buildBg(constraints.maxWidth, constraints.maxHeight),
              buildTunnel(),
              Container(
                padding: EdgeInsets.only(
                    top: max(0, (110.w + padding.top) - (1600.w - 1334.h) / 2)),
                // 使元素处在合适位置
                height: 1334.w,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // 核心元素
                    Positioned(
                      top: 130.w,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 15.w,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: 14.w, right: 14.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      buildTopButtons(),
                      buildBottomButtons(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTunnel() {
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: Image.asset(
            'assets/game/bg_tunnel_top.png',
            height: 252.w,
            width: 98.w,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Image.asset(
            'assets/game/bg_tunnel_top.png',
            height: 252.w,
            width: 98.w,
            fit: BoxFit.fill,
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: Image.asset(
              'assets/game/bg_tunnel_center.png',
              height: 310.w,
              width: 98.w,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Image.asset(
            'assets/game/bg_tunnel_bottom.png',
            height: 252.w,
            width: 98.w,
            fit: BoxFit.fill,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Image.asset(
            'assets/game/bg_tunnel_bottom.png',
            height: 252.w,
            width: 98.w,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }

  Widget buildBg(double width, double height) {
    double imgHeight = 1624 * width / 750;
    double top = (height - imgHeight) / 2;
    if (top > 0) {
      top = 0;
    }
    return Positioned(
      top: top,
      child: Image.asset('assets/game/bg_speedway.png'),
      width: width,
      height: imgHeight,
    );
  }
}
