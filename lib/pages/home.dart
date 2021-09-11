import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/GameLevel.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/assets_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/pet_shop_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/swap_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/talking_dialog.dart';
import 'package:kingspro/pages/game/game1_dialog.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/Web3Util.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';

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
        $t('关卡 1'), ColorConstant.bg_level_1, ColorConstant.bg_level_9));
    levels.add(GameLevel(
        $t('关卡 2'), ColorConstant.bg_level_2, ColorConstant.bg_level_9));
    levels.add(
        GameLevel($t('关卡 3'), ColorConstant.bg_level_3, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 4'), ColorConstant.bg_level_4, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 5'), ColorConstant.bg_level_5, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 6'), ColorConstant.bg_level_6, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 7'), ColorConstant.bg_level_7, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 8'), ColorConstant.bg_level_8, ColorConstant.title));
    // levels.add(
    //     GameLevel($t('关卡 9'), ColorConstant.bg_level_9, ColorConstant.title));
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
        ConfigModel.getInstance().refresh();
        break;
      case AppLifecycleState.paused: // 应用程序不可见，后台
        break;
      case AppLifecycleState.detached: // 申请将暂时暂停
        break;
    }
  }

  showShop() {
    BottomDialog.showDialog(context, PetShopDialog());
  }

  showExchange() {}

  showRank() {
    // BottomDialog.showDialog(context, RankDialog());
  }

  showTalking() {
    BottomDialog.showDialog(context, TalkingDialog());
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

  buildCard() {
    return Consumer<AccountModel>(
      builder: (context, accountModel, child) {
        return ShadowContainer(
          width: double.maxFinite,
          height: 260.w,
          margin: EdgeInsets.only(
            bottom: 60.w,
            top: 40.w,
            left: 40.w,
            right: 40.w,
          ),
          padding: EdgeInsets.all(20.w),
          color: ColorConstant.homeCardBg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                accountModel.name ?? "",
                maxLines: 1,
                minFontSize: 10,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: SizeConstant.h7,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TouchDownScale(
                onTap: () {
                  ClipboardData data =
                      new ClipboardData(text: accountModel.account);
                  Clipboard.setData(data);
                  ToastUtil.showToast(
                    $t("已复制"),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(top: 6.w, bottom: 6.w),
                  child: AutoSizeText(
                    accountModel.account,
                    maxLines: 1,
                    minFontSize: 10,
                    style: TextStyle(
                      fontSize: SizeConstant.h9,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(child: Container()),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // alignment: AlignmentDirectional.center,
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
                                fontSize: SizeConstant.h5,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(
                          height: 6.w,
                        ),
                        Container(
                          // alignment: AlignmentDirectional.center,
                          child: AutoSizeText(
                            null == accountModel.gameTokenBalance
                                ? ''
                                : NumberUtil.decimalNumString(
                                      num: accountModel.gameTokenBalance
                                          .toString(),
                                      fractionDigits: 0,
                                    ) +
                                    ' ' +
                                    ConfigConstants.gameTokenSymbol,
                            maxLines: 1,
                            minFontSize: 10,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: SizeConstant.h5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TouchDownScale(
                    child: ShadowContainer(
                      width: 120.w,
                      height: 64.w,
                      color: ColorConstant.titleBg,
                      child: Center(
                        child: Text(
                          $t('兑换'),
                          style: TextStyle(
                            color: ColorConstant.title,
                            fontSize: SizeConstant.h7,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      BottomDialog.showDialog(context, SwapDialog());
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  buildTab(String tab, Function onTabClick) {
    return Expanded(
      child: TouchDownScale(
        child: Center(
          child: Text(
            tab,
            style: TextStyle(
              color: ColorConstant.titleBg,
              fontSize: SizeConstant.h6,
            ),
          ),
        ),
        onTap: onTabClick,
      ),
    );
  }

  buildBottomButtons() {
    return Container(
      height: 96.w,
      decoration: BoxDecoration(
        color: ColorConstant.title,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, //横轴居中对齐(默认)
        children: [
          buildTab($t('商店'), showShop),
          buildTab($t('背包'), showAssets),
          buildTab($t('聊天'), showTalking),
          buildTab($t('排行榜'), showRank),
        ],
      ),
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
            bottom: 40.w,
            left: 40.w,
            right: 40.w,
          ),
          child: TouchDownScale(
            onTap: () {
              BottomDialog.showDialog(
                context,
                Game1Dialog(
                  difficulty: index + 1,
                ),
              );
            },
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
        ),
      );
    }
    return gameList;
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return Scaffold(
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildCard(),
                    Expanded(
                      child: GridView(
                        padding: EdgeInsets.only(top: 0, bottom: 0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                        ),
                        children: buildGameList(),
                        physics: AlwaysScrollableScrollPhysics(),
                      ),
                    ),
                    SizedBox(
                      height: 40.w,
                    ),
                    buildBottomButtons(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
