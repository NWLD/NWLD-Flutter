import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/entity/PetUpdateInfo.dart';
import 'package:kingspro/entity/TransactionInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/transaction_confirm_dialog.dart';
import 'package:kingspro/pages/pet/select_switch_dialog.dart';
import 'package:kingspro/service/PetService.dart';
import 'package:kingspro/service/PetSwitchRoleService.dart';
import 'package:kingspro/service/TokenService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/base_button.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:web3dart/web3dart.dart';

import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

class SwitchRoleDialog extends StatefulWidget {
  final PetInfo petInfo;

  SwitchRoleDialog({Key key, this.petInfo}) : super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<SwitchRoleDialog>
    with BaseLocalizationsStateMixin {
  PetInfo _petInfo;
  int switchWho = 0;

  PetUpdateInfo _updateInfo;
  BigInt _allowance;

  @override
  void initState() {
    _petInfo = widget.petInfo;
    getInfo();
    getAllowance();
    getPetAllowance();
    super.initState();
  }

  void getInfo() async {
    try {
      PetUpdateInfo updateInfo =
          await PetSwitchRoleService.getInfo(widget.petInfo.tokenId);
      setState(() {
        _updateInfo = updateInfo;
      });
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  void getAllowance() async {
    BigInt allowance = await TokenService.allowance(
      ConfigModel.getInstance().config(ConfigConstants.petSwitchRole),
    );
    setState(() {
      _allowance = allowance;
    });
  }

  void approve() async {
    try {
      Transaction transaction = await TokenService.approve(
        ConfigModel.getInstance().config(ConfigConstants.petSwitchRole),
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

  bool _isPetApproved = false;

  void getPetAllowance() async {
    bool allowance = await PetService.isApprovedForAll(
      ConfigModel.getInstance().config(ConfigConstants.petSwitchRole),
    );
    setState(() {
      _isPetApproved = allowance;
    });
  }

  void approvePet() async {
    try {
      Transaction transaction = await PetService.approveAll(
        ConfigModel.getInstance().config(ConfigConstants.petSwitchRole),
      );
      TransactionInfo transactionInfo = TransactionInfo(
        transaction,
        $t('授权 NFT'),
      );
      String hash =
          await TransactionConfirmDialog.send(context, transactionInfo);
      if (StringUtils.isEmpty(hash)) {
        return;
      }
      confirmPetApprove(hash);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  PeriodicTimer _approvePetPeriodicTimer;

  void confirmPetApprove(String hash) async {
    EasyLoading.show(dismissOnTap: true);
    if (null != _approvePetPeriodicTimer) {
      return;
    }
    _approvePetPeriodicTimer = PeriodicTimer();
    _approvePetPeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _approvePetPeriodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _approvePetPeriodicTimer.cancel(false);
            ToastUtil.showToast($t('授权失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _approvePetPeriodicTimer.cancel(false);
            setState(() {
              _isPetApproved = true;
            });
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        EasyLoading.dismiss();
        _cancelApprovePetPeriodicTimer();
      },
    );
  }

  void _cancelApprovePetPeriodicTimer() {
    if (null != _approvePetPeriodicTimer) {
      _approvePetPeriodicTimer.cancel(false);
      _approvePetPeriodicTimer = null;
    }
  }

  void switchRole() async {
    if (0 == switchWho) {
      ToastUtil.showToast($t('请选择卡牌'), type: ToastType.warning);
      return;
    }
    try {
      Transaction transaction = await PetSwitchRoleService.switchRole(
          widget.petInfo.tokenId, switchWho);
      TransactionInfo transactionInfo = TransactionInfo(
        transaction,
        '0 ' + SettingsModel.getInstance().currentChain().symbol,
      );
      String hash =
          await TransactionConfirmDialog.send(context, transactionInfo);
      if (StringUtils.isEmpty(hash)) {
        return;
      }
      confirmUpgrade(hash);
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  void checkSwitchRoleStatus() async {
    EasyLoading.show(dismissOnTap: true);
    try {
      String address = await PetService.ownerOf(widget.petInfo.tokenId);
      if (StringUtils.isEqualIgnore(address, ConfigConstants.deadAddress)) {
        ToastUtil.showToast($t('变身成功'), type: ToastType.success);
        Navigator.of(context).pop('1');
      } else {
        ToastUtil.showToast($t('变身失败'), type: ToastType.warning);
      }
    } catch (e) {
      //没办法确认是否已经变身成功
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  PeriodicTimer _upgradePeriodicTimer;

  void confirmUpgrade(String hash) async {
    EasyLoading.show(dismissOnTap: true);
    if (null != _upgradePeriodicTimer) {
      return;
    }
    _upgradePeriodicTimer = PeriodicTimer();
    _upgradePeriodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () async {
        try {
          int hashStatus = await TransactionService.getStatus(hash);
          if (null == _upgradePeriodicTimer || 0 == hashStatus) {
            return;
          }
          if (2 == hashStatus) {
            _upgradePeriodicTimer.cancel(false);
            ToastUtil.showToast($t('变身失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _upgradePeriodicTimer.cancel(false);
            //确认变身是否成功，查看当前卡牌是否属于dead地址
            checkSwitchRoleStatus();
          }
        } catch (e) {
          ToastUtil.showToast(e.toString(), type: ToastType.error);
        } finally {}
      },
      onEnd: (max) {
        EasyLoading.dismiss();
        _cancelUpgradePeriodicTimer();
      },
    );
  }

  void _cancelUpgradePeriodicTimer() {
    if (null != _upgradePeriodicTimer) {
      _upgradePeriodicTimer.cancel(false);
      _upgradePeriodicTimer = null;
    }
  }

  @override
  dispose() {
    _cancelUpgradePeriodicTimer();
    _cancelApprovePeriodicTimer();
    _cancelApprovePetPeriodicTimer();
    super.dispose();
  }

  Widget buildButton() {
    //授权代币
    if (null == _allowance || _allowance < _updateInfo.price) {
      return BaseButton(
        title: $t('授权'),
        onTap: approve,
        width: 100.w,
        height: 50.w,
        bg: ColorConstant.bg_level_9,
        fontSize: SizeConstant.h9,
      );
    }
    //授权NFT
    if (!_isPetApproved) {
      return BaseButton(
        title: $t('授权'),
        onTap: approvePet,
        width: 100.w,
        height: 50.w,
        bg: ColorConstant.bg_level_9,
        fontSize: SizeConstant.h9,
      );
    }
    return BaseButton(
      title: $t('变身'),
      onTap: switchRole,
      width: 100.w,
      height: 50.w,
      bg: ColorConstant.bg_level_9,
      fontSize: SizeConstant.h9,
    );
  }

  void selectPet() {
    BottomDialog.showDialog(
      context,
      SelectSwitchRolePetDialog(
        petInfo: widget.petInfo,
        onWhoSelected: (int who) {
          setState(() {
            switchWho = who;
          });
        },
      ),
    );
  }

  Widget buildCard(int who) {
    return ShadowContainer(
      width: 240.w,
      height: 400.w,
      color: _petInfo.rareBg(),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pet/pet_$who.png',
            width: 240.w,
            height: 240.w,
          ),
          Text(
            $t('pet_$who'),
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h8,
            ),
          ),
          SizedBox(
            height: 16.w,
          ),
          Text(
            _petInfo.level.toString() + "星",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _petInfo.getFight().toString() + " " + $t("战力"),
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSelectButton() {
    return 0 == switchWho
        ? BaseButton(
            width: 240.w,
            height: 400.w,
            title: $t('选择卡牌'),
            onTap: selectPet,
            bg: ColorConstant.bg_level_9,
          )
        : BaseButton(
            width: 240.w,
            height: 400.w,
            padding: EdgeInsets.all(0),
            onTap: selectPet,
            bg: _petInfo.rareBg(),
            child: buildCard(switchWho),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("变身"),
      content: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(_petInfo.who),
              Padding(
                padding: EdgeInsets.only(left: 40.w, right: 40.w),
                child: Text(
                  '-->',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildSelectButton(),
            ],
          ),
          SizedBox(
            height: 40.w,
          ),
          ShadowContainer(
            width: 690.w,
            height: 200.w,
            margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
            padding: EdgeInsets.all(20.w),
            color: ColorConstant.titleBg,
            child: null == _updateInfo
                ? Container()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        $t('价格') + ": " + _updateInfo.priceLabel(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConstant.h8,
                        ),
                      ),
                      SizedBox(
                        height: 6.w,
                      ),
                      Text(
                        $t('成功率') + ": " + _updateInfo.rate,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConstant.h8,
                        ),
                      ),
                      Expanded(child: Container()),
                      buildButton(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
