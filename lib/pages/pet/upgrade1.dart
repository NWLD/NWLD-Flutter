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
import 'package:kingspro/service/PetService.dart';
import 'package:kingspro/service/PetUpgrade1Service.dart';
import 'package:kingspro/service/TokenService.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/widgets/base_button.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:web3dart/web3dart.dart';

import '../../l10n/base_localizations.dart';

class UpgradeItem1 extends StatefulWidget {
  final PetInfo petInfo;

  UpgradeItem1({Key key, this.petInfo}) : super(key: key);

  @override
  _UpgradeItem1State createState() => _UpgradeItem1State();
}

class _UpgradeItem1State extends State<UpgradeItem1>
    with BaseLocalizationsStateMixin {
  PetUpdateInfo _updateInfo;
  BigInt _allowance;

  @override
  void initState() {
    getInfo();
    getAllowance();
    getPetAllowance();
    super.initState();
  }

  void getInfo() async {
    try {
      PetUpdateInfo updateInfo =
          await PetUpgrade1Service.getInfo(widget.petInfo.tokenId);
      setState(() {
        _updateInfo = updateInfo;
      });
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    }
  }

  void getAllowance() async {
    BigInt allowance = await TokenService.allowance(
      ConfigModel.getInstance().config(ConfigConstants.petUpgrade1),
    );
    setState(() {
      _allowance = allowance;
    });
  }

  void approve() async {
    try {
      Transaction transaction = await TokenService.approve(
        ConfigModel.getInstance().config(ConfigConstants.petUpgrade1),
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
      ConfigModel.getInstance().config(ConfigConstants.petUpgrade1),
    );
    setState(() {
      _isPetApproved = allowance;
    });
  }

  void approvePet() async {
    try {
      Transaction transaction = await PetService.approveAll(
        ConfigModel.getInstance().config(ConfigConstants.petUpgrade1),
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

  void upgrade() async {
    try {
      Transaction transaction =
          await PetUpgrade1Service.upgrade(widget.petInfo.tokenId);
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

  void checkUpgradeStatus() async {
    EasyLoading.show(dismissOnTap: true);
    try {
      String address = await PetService.ownerOf(widget.petInfo.tokenId);
      if (StringUtils.isEqualIgnore(address, ConfigConstants.deadAddress)) {
        ToastUtil.showToast($t('升级成功'), type: ToastType.success);
        Navigator.of(context).pop('1');
      } else {
        ToastUtil.showToast($t('升级失败'), type: ToastType.warning);
      }
    } catch (e) {
      //没办法确认是否已经升级成功
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
            ToastUtil.showToast($t('升级失败'), type: ToastType.error);
            return;
          }
          if (1 == hashStatus) {
            AccountModel.getInstance().getBalance();
            _upgradePeriodicTimer.cancel(false);
            //确认升级是否成功，查看当前卡牌是否属于dead地址
            checkUpgradeStatus();
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
      title: $t('升级'),
      onTap: upgrade,
      width: 100.w,
      height: 50.w,
      bg: ColorConstant.bg_level_9,
      fontSize: SizeConstant.h9,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
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
    );
  }
}
