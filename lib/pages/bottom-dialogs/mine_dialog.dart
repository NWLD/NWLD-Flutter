import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';
import '../../constants/urls.dart';
import '../../l10n/base_localizations.dart';
import '../../routes/routes.dart';
import '../../util/client_utils.dart';
import '../../widgets/beautify_avatar.dart';
import '../../widgets/gradual_linear_progress_bar.dart';
import 'bottom_dialog_container.dart';

class MineDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MineDialogState();
  }
}

class MineDialogState extends State<MineDialog>
    with BaseLocalizationsStateMixin {
  String version = "1.0.0";

  @override
  void initState() {
    getPackageInfo();
    super.initState();
  }

  void getPackageInfo() async {
    version = await ClientUtils.getAppVersion();

    setState(() {});
  }

  Widget getPersonalInfoWidget(AccountModel accountModel) {
    return Container(
      width: 672.w,
      height: 280.w,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
              top: 50.w,
              child: Container(
                height: 220.w,
                width: 672.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(25, 29, 41, 1),
                  borderRadius: BorderRadius.all(
                    const Radius.circular(8.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.6),
                      offset: Offset(0, 6.w),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Positioned(
                      top: 70.w,
                      child: Text(
                        accountModel.name,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConstant.h3,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 140.w,
                      child: Text(
                        "ID : " + accountModel.account,
                        style: TextStyle(
                          color: Color.fromRGBO(170, 181, 197, 1),
                          fontSize: SizeConstant.h9,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          Positioned(
              top: 0,
              child: BeautifyAvatar(
                avatar: '',
              )),
        ],
      ),
    );
  }

  Widget formatItemCell(
      String title, String subTitle, Color subTitleColor, String routeName) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (ev) {},
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        padding: EdgeInsets.only(
          left: 30.w,
          right: 30.w,
          top: 15.w,
          bottom: 15.w,
        ),
        height: 120.w,
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(170, 181, 197, 1),
                    fontSize: SizeConstant.h9,
                  ),
                ),
                Text(
                  subTitle,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: subTitleColor,
                    fontSize: 34.w,
                  ),
                ),
              ],
            ),
            Expanded(child: SizedBox()),
            Image.asset(
              "assets/mine/ic_arrow.png",
              width: 25.w,
              height: 24.w,
            )
          ],
        ),
      ),
    );
  }

  Widget getMineWallet(AccountModel accountModel) {
    return Container(
      height: 242.w,
      width: 672.w,
      decoration: BoxDecoration(
        color: Color.fromRGBO(25, 29, 41, 1),
        borderRadius: BorderRadius.all(
          const Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.6),
            offset: Offset(0, 6.w),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          formatItemCell(
            $t("我的钱包"),
            '',
            ColorConstant.title,
            RouteMap.wallet,
          ),
          SizedBox(
            child: Container(
              height: 2.w,
              color: Colors.black,
            ),
          ),
          formatItemCell(
            $t("邀请收益"),
            '',
            ColorConstant.title,
            RouteMap.team,
          ),
        ],
      ),
    );
  }

  Widget getMineInviteCode(AccountModel accountModel) {
    return Container(
      height: 242.w,
      width: 672.w,
      decoration: BoxDecoration(
        color: Color.fromRGBO(25, 29, 41, 1),
        borderRadius: BorderRadius.all(
          const Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.6),
            offset: Offset(0, 6.w),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          formatItemCell(
            $t("我的邀请码"),
            '',
            ColorConstant.title,
            RouteMap.mineInviteCode,
          ),
          SizedBox(
            child: Container(
              height: 2.w,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget switchItem(String title, bool switchOn, Function onTap) {
    return GestureDetector(
      onTapDown: (ev) {},
      onTap: onTap,
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: Color.fromRGBO(208, 230, 249, 1),
                fontSize: 34.w,
              ),
            ),
            SizedBox(
              width: 24.w,
            ),
            Image.asset(
              switchOn
                  ? "assets/mine/switch_on.png"
                  : "assets/mine/switch_off.png",
              width: 102.w,
              height: 62.w,
            )
          ],
        ),
      ),
    );
  }

  Widget getAppSoundSetting(SettingsModel settingsModel) {
    return Container(
      height: 120.w,
      width: 672.w,
      padding: EdgeInsets.only(
        left: 30.w,
        right: 30.w,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Color.fromRGBO(25, 29, 41, 1),
        borderRadius: BorderRadius.all(
          const Radius.circular(8.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.6),
            offset: Offset(0, 6.w),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[

        ],
      ),
    );
  }

  Widget linkItem(String title, String routeName) {
    return GestureDetector(
      onTapDown: (ev) {
        // AppAudioPlayerManager.playSoundEffects(SoundEffectsStyle.CLICK);
      },
      onTap: () {
        RouteUtils.openWebview(
          context,
          routeName,
          title,
        );
      },
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          decoration: TextDecoration.underline,
          color: Colors.black,
          fontSize: SizeConstant.h10,
        ),
      ),
    );
  }

  Widget getListViewFooterView() {
    return Container(
      width: 750.w,
      height: 120.w,
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: SizedBox(),
              ),
              Expanded(child: SizedBox()),
            ],
          ),
          SizedBox(
            height: 15.w,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccountModel, SettingsModel>(
        builder: (context, accountModel, settingsModel, child) {
      return BottomDialogContainer(
        title: $t("我的"),
        content: ListView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 0.w,
          ),
          children: <Widget>[
            //1、个人信息
            getPersonalInfoWidget(
              accountModel,
            ),
            SizedBox(
              height: 30.w,
            ),
            //2、钱包
            getMineWallet(accountModel),
            SizedBox(
              height: 30.w,
            ),
            // 3、邀请码、渠道合伙人
            getMineInviteCode(accountModel),
            SizedBox(
              height: 30.w,
            ),
            //音效、音乐设置
            getAppSoundSetting(settingsModel),
            SizedBox(
              height: 60.w,
            ),
            //用户协议、隐私协议
            getListViewFooterView(),
          ],
        ),
      );
    });
  }
}
