import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/entity/GameLevel.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/assets_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/shop_dialog.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/web3/Web3Util.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/flip.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/beautify_avatar.dart';
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
        height: height ?? 120.w,
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
  //游戏等级
  List<GameLevel> gameLevels = [];

  void initGame() async {
    List<GameLevel> levels = [];
    levels.add(GameLevel(
        $t('新手上路'), ColorConstant.bg_level_1, ColorConstant.bg_level_9));
    levels.add(GameLevel(
        $t('牛刀小试'), ColorConstant.bg_level_2, ColorConstant.bg_level_9));
    levels.add(
        GameLevel($t('炉火纯青'), ColorConstant.bg_level_3, ColorConstant.title));
    levels.add(
        GameLevel($t('名震八方'), ColorConstant.bg_level_4, ColorConstant.title));
    levels.add(
        GameLevel($t('功绩显赫'), ColorConstant.bg_level_5, ColorConstant.title));
    levels.add(
        GameLevel($t('震古铄今'), ColorConstant.bg_level_6, ColorConstant.title));
    levels.add(
        GameLevel($t('超凡入圣'), ColorConstant.bg_level_7, ColorConstant.title));
    levels.add(
        GameLevel($t('天人合一'), ColorConstant.bg_level_8, ColorConstant.title));
    levels.add(
        GameLevel($t('破碎虚空'), ColorConstant.bg_level_9, ColorConstant.title));
    setState(() {
      gameLevels = levels;
    });
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    Future.delayed(Duration(milliseconds: 30), initGame);
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
        AccountModel().getBalance();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  showShop() {
    BottomDialog.showDialog(context, ShopDialog());
  }

  showExchange() {}

  showRank() {
    // BottomDialog.showDialog(context, RankDialog());
  }

  showPersonalCenter() {
    // BottomDialog.showDialog(context, MineDialog());
  }

  showAssets() async {
    if (LoginDialog.shouldShow(context)) {
      return;
    }
    BottomDialog.showDialog(context, AssetsDialog());
    LogUtil.log('account', AccountModel.getInstance().account);
    LogUtil.log('privateKey', AccountModel.getInstance().decodePrivateKey());
    AccountModel.getInstance().getBalance();
    print(await Web3Util().web3Client().getBlockNumber());
  }

  buildAvatar() {
    return Consumer<AccountModel>(
      builder: (context, accountModel, child) {
        return Padding(
          padding: EdgeInsets.only(top: 20.w),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Positioned(
                left: 0.w,
                width: 324.w,
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
                            accountModel.name ?? "",
                            maxLines: 1,
                            minFontSize: 10,
                            textAlign: TextAlign.start,
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
                            StringUtils.simpleAccount(accountModel.account),
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
          ),
        );
      },
    );
  }

  buildBalance() {
    return Consumer<AccountModel>(
      builder: (context, accountModel, child) {
        return Container(
            transform: Matrix4.translationValues(0, -10.w, 0),
            width: 220.w,
            height: 152.w,
            padding: EdgeInsets.only(
                bottom: 32.w, left: 26.w, right: 20.w, top: 48.w),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/game/button_buy.png'),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 180.w,
                  child: AutoSizeText(
                    null == accountModel.gameTokenBalance
                        ? ''
                        : NumberUtil.decimalNumString(
                              num: accountModel.gameTokenBalance.toString(),
                              fractionDigits: 0,
                            ) +
                            ' ' +
                            SettingsModel().currentChain().gameTokenSymbol,
                    maxLines: 1,
                    minFontSize: 10,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: SizeConstant.h8,
                      fontFamily: "CarterOne-Regular",
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: 8.w,
                ),
                Container(
                  width: 180.w,
                  child: AutoSizeText(
                    null == accountModel.balance
                        ? ''
                        : NumberUtil.decimalNumString(
                              num: accountModel.balance.toString(),
                              fractionDigits: 4,
                            ) +
                            ' ' +
                            SettingsModel().currentChain().symbol,
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(
                      fontSize: SizeConstant.h9,
                      fontFamily: "CarterOne-Regular",
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }

  buildTopButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: buildAvatar(),
          flex: 1,
        ),
        buildBalance(),
      ],
    );
  }

  buildAssetsButton() {
    return GeneralHomeButton(
      text: $t('资产'),
      image: 'assets/game/button_invite.png',
      width: 176.w,
      onTap: showAssets,
    );
  }

  buildExchangeButton() {
    return GeneralHomeButton(
      text: $t('交易市场'),
      image: 'assets/game/button_store.png',
      width: 176.w,
      onTap: showExchange,
    );
  }

  buildBottomButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end, //横轴居中对齐(默认)
      children: [
        Expanded(
          flex: 3,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: GeneralHomeButton(
              text: $t('礼包'),
              image: 'assets/game/button_luckydraw.png',
              width: 120.w,
              onTap: showShop,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: buildAssetsButton(),
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: buildExchangeButton(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            alignment: AlignmentDirectional.center,
            child: GeneralHomeButton(
              text: $t('排行榜'),
              image: 'assets/game/button_rank.png',
              width: 120.w,
              onTap: showRank,
            ),
          ),
        ),
      ],
    );
  }

  buildGameList() {
    List gameList = <Widget>[];
    int len = gameLevels.length;
    for (int index = 0; index < len; index++) {
      GameLevel gameLevel = gameLevels[index];
      gameList.add(
        Container(
          margin: EdgeInsets.only(
            bottom: 60.w,
          ),
          child: ShadowContainer(
            width: null,
            height: 180.w,
            color: gameLevel.bg,
            child: Container(
              alignment: AlignmentDirectional.center,
              child: Text(
                gameLevel.title,
                style: TextStyle(
                  color: gameLevel.color,
                  fontSize: SizeConstant.h4,
                ),
              ),
            ),
          ),
        ),
      );
    }
    return gameList;
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
                    children: [
                      buildTopButtons(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 120.w,
                            bottom: 60.w,
                            right: 120.w,
                            top: 40.w,
                          ),
                          child: ListView(
                            children: buildGameList(),
                          ),
                        ),
                      ),
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
