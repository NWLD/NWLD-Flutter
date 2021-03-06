import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightPet.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/TransactionInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/login_dialog.dart';
import 'package:kingspro/pages/bottom-dialogs/transaction_confirm_dialog.dart';
import 'package:kingspro/pages/game/fight_result_dialog.dart';
import 'package:kingspro/pages/game/select_fight_dialog.dart';
import 'package:kingspro/service/GameService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/auto_fontSize_text.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

class GameDialog extends StatefulWidget {
  final int difficulty;

  GameDialog({Key key, this.difficulty = 1}) : super(key: key);

  @override
  _GameDialogState createState() => _GameDialogState();
}

class _GameDialogState extends State<GameDialog>
    with BaseLocalizationsStateMixin {
  FightPet _fightHero;
  FightReward _fightReward;
  int _fightCount = 1;

  String _address;
  GameService _gameService;

  @override
  void initState() {
    String config = ConfigConstants.game3;
    if (2 == widget.difficulty) {
      config = ConfigConstants.game2;
    } else if (1 == widget.difficulty) {
      config = ConfigConstants.game1;
    }
    _address = ConfigModel.getInstance().config(config);
    _gameService = GameService(config, _address);
    getFightInfo();
    super.initState();
  }

  void getFightInfo() async {
    FightReward fightReward = await _gameService.getFightReward();
    setState(() {
      _fightReward = fightReward;
    });
  }

  PeriodicTimer _periodicTimer;

  void getFightResult(String hash, int fightCount) {
    cancelPeriodicTimer();
    EasyLoading.show(dismissOnTap: true);
    _periodicTimer = PeriodicTimer();
    _periodicTimer.start(
      milliseconds: 3000,
      maxCount: 10,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _periodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _periodicTimer.cancel(false);
            ToastUtil.showToast($t('????????????'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _periodicTimer.cancel(false);
            List<int> results =
                await _gameService.getFightResults(_fightHero.heroInfo.tokenId);
            setState(() {
              _fightHero.fightCount -= fightCount;
              _fightCount = 1;
              if (_fightHero.fightCount <= 0) {
                _fightHero = null;
              }
            });
            BottomDialog.showDialog(
              context,
              FightResultDialog(
                results: results,
                fightReward: _fightReward,
              ),
            );
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        EasyLoading.dismiss();
        cancelPeriodicTimer();
      },
    );
  }

  void cancelPeriodicTimer() {
    if (null != _periodicTimer) {
      _periodicTimer.cancel(false);
      _periodicTimer = null;
    }
  }

  @override
  dispose() {
    cancelPeriodicTimer();
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
        title: $t("??????"),
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
                                '??????',
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
                            //????????????
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
                            //????????????
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
                                      '???????????? ',
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
                                      '?????? ',
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
                    if (LoginDialog.shouldShow(context)) {
                      return;
                    }
                    BottomDialog.showDialog(
                      context,
                      SelectFightHeroDialog(
                        difficulty: widget.difficulty,
                        onFightHeroSelected: (fightHero) {
                          setState(() {
                            _fightHero = fightHero;
                          });
                        },
                      ),
                    );
                  },
                  child: null == _fightHero
                      ? ShadowContainer(
                          width: 315.w,
                          height: 426.w,
                          color: ColorConstant.bg_level_9,
                          child: Center(
                            child: Text(
                              $t(
                                '????????????',
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
                                'assets/pet/pet_${_fightHero.heroInfo.who}.png',
                                width: 200.w,
                                height: 200.w,
                                fit: BoxFit.fill,
                              ),
                              Text(
                                $t('pet_${_fightHero.heroInfo.who}'),
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
                                _fightHero.heroInfo.level.toString() + "???",
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
                                    " ??????",
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
            ),
            SizedBox(
              height: 40.w,
            ),
            if (null != _fightHero)
              Row(
                children: [
                  SizedBox(
                    width: 40.w,
                  ),
                  TouchDownScale(
                    child: Image.asset(
                      'assets/common/num_minus.png',
                      width: 54.w,
                      height: 54.w,
                    ),
                    onTap: () {
                      if (_fightCount <= 1) {
                        return;
                      }
                      setState(() {
                        _fightCount--;
                      });
                    },
                  ),
                  Container(
                    width: 80.w,
                    child: Center(
                      child: Text(
                        _fightCount.toString(),
                        style: TextStyle(
                          color: ColorConstant.title,
                          fontSize: SizeConstant.h7,
                        ),
                      ),
                    ),
                  ),
                  TouchDownScale(
                    child: Image.asset(
                      'assets/common/num_add.png',
                      width: 54.w,
                      height: 54.w,
                    ),
                    onTap: () {
                      if (_fightCount >= _fightHero.fightCount) {
                        return;
                      }
                      setState(() {
                        _fightCount++;
                      });
                    },
                  ),
                  SizedBox(
                    width: 40.w,
                  ),
                  TouchDownScale(
                    child: ShadowContainer(
                      width: 80.w,
                      height: 54.w,
                      color: ColorConstant.bg_level_4,
                      child: Center(
                        child: Text(
                          'Max',
                          style: TextStyle(
                            color: ColorConstant.title,
                            fontSize: SizeConstant.h8,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _fightCount = _fightHero.fightCount;
                      });
                    },
                  ),
                  SizedBox(
                    width: 40.w,
                  ),
                  TouchDownScale(
                    onTap: () async {
                      try {
                        Transaction transaction = await _gameService.fight(
                          _fightHero.heroInfo.tokenId,
                          _fightCount,
                        );
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
                        getFightResult(hash, _fightCount);
                      } catch (e) {
                        ToastUtil.showToast(e.toString(),
                            type: ToastType.error);
                      }
                    },
                    child: ShadowContainer(
                      width: 120.w,
                      height: 54.w,
                      color: ColorConstant.titleBg,
                      child: Center(
                        child: Text(
                          $t('??????'),
                          style: TextStyle(
                            color: ColorConstant.title,
                            fontSize: SizeConstant.h8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      );
    });
  }
}
