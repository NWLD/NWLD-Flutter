import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightHero.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/entity/TokenPoolInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/pages/game/select_fight_dialog.dart';
import 'package:kingspro/service/SimpleGameService.dart';
import 'package:kingspro/service/TokenPoolService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';
import 'package:provider/provider.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

class Game1Dialog extends StatefulWidget {
  @override
  _Game1DialogState createState() => _Game1DialogState();
}

class _Game1DialogState extends State<Game1Dialog>
    with BaseLocalizationsStateMixin {
  FightHero _fightHero;
  FightReward _fightReward;

  @override
  void initState() {
    getFightInfo();
    super.initState();
  }

  void getFightInfo() async {
    FightReward fightReward = await SimpleGameService.getFightReward(1);
    setState(() {
      _fightReward = fightReward;
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
          setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(builder: (context, accountModel, child) {
      return BottomDialogContainer(
          title: $t("试炼"),
          content: Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 40.w,
                  ),
                  ShadowContainer(
                    width: 315.w,
                    height: 426.w,
                    color: ColorConstant.bg_level_9,
                    child: null == _fightReward
                        ? Container()
                        : Column(
                            children: [
                              SizedBox(
                                height: 40.w,
                              ),
                              Text(
                                $t(
                                  '奖励',
                                ),
                                style: TextStyle(
                                  color: ColorConstant.title,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConstant.h8,
                                ),
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              //奖励代币
                              Text(
                                NumberUtil.decimalNumString(
                                        num: _fightReward.token.toString(),
                                        fractionDigits: 0) +
                                    ' ' +
                                    ConfigConstants.gameTokenSymbol,
                                style: TextStyle(
                                  color: ColorConstant.title,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConstant.h8,
                                ),
                              ),
                              SizedBox(
                                height: 6.w,
                              ),
                              //奖励经验
                              Text(
                                _fightReward.exp.toString() + ' exp',
                                style: TextStyle(
                                  color: ColorConstant.title,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConstant.h8,
                                ),
                              ),
                              SizedBox(
                                height: 40.w,
                              ),
                              if (null != _fightHero)
                                Text(
                                  $t(
                                        '剩余次数 ',
                                      ) +
                                      _fightHero.fightCount.toString(),
                                  style: TextStyle(
                                    color: ColorConstant.title,
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConstant.h8,
                                  ),
                                ),
                              SizedBox(
                                height: 6.w,
                              ),
                              if (null != _fightHero)
                                Text(
                                  $t(
                                        '胜率 ',
                                      ) +
                                      _fightHero.winRate.toString() +
                                      '%',
                                  style: TextStyle(
                                    color: ColorConstant.title,
                                    fontWeight: FontWeight.bold,
                                    fontSize: SizeConstant.h8,
                                  ),
                                ),
                            ],
                          ),
                  ),
                  SizedBox(
                    width: 40.w,
                  ),
                  TouchDownScale(
                    onTap: () {
                      BottomDialog.showDialog(context, SelectFightHeroDialog());
                    },
                    child: null == _fightHero
                        ? ShadowContainer(
                            width: 315.w,
                            height: 426.w,
                            color: ColorConstant.bg_level_9,
                            child: Center(
                              child: Text(
                                $t(
                                  '选择卡牌',
                                ),
                                style: TextStyle(
                                  color: ColorConstant.title,
                                  fontWeight: FontWeight.bold,
                                  fontSize: SizeConstant.h8,
                                ),
                              ),
                            ),
                          )
                        : ShadowContainer(
                            width: 335.w,
                            height: 426.w,
                            color: _fightHero.heroInfo.rareBg(),
                            padding: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/hero/hero_${_fightHero.heroInfo.who}.png',
                                  width: 200.w,
                                  height: 200.w,
                                ),
                                Text(
                                  $t('hero_${_fightHero.heroInfo.who}'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConstant.h8,
                                  ),
                                ),
                                SizedBox(
                                  height: 16.w,
                                ),
                                Text(
                                  _fightHero.heroInfo.rareLabel(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConstant.h8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  _fightHero.heroInfo.level.toString() + "星",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConstant.h8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 6.w,
                                ),
                                Text(
                                  _fightHero.heroInfo.getFight().toString() +
                                      " 战力",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: SizeConstant.h8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              )
            ],
          ));
    });
  }
}
