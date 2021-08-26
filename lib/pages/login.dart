import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';

import '../constants/sizes.dart';
import '../l10n/base_localizations.dart';
import '../routes/routes.dart';
import '../util/client_utils.dart';
import '../widgets/toast_util.dart';
import 'base_will_pop_scope.dart';

enum LoginPlatform {
  local,
  simulate,
  facebook,
  apple,
}

class LoginPage extends StatefulWidget {
  final bool accessTokenIsExpire;

  LoginPage({
    this.accessTokenIsExpire = false,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with BaseLocalizationsStateMixin {

  TextEditingController textEditingController;

  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  login() async {
    EasyLoading.show(maskType: EasyLoadingMaskType.clear);
    try {
      Navigator.pushReplacementNamed(context, RouteMap.game);
    } catch (e) {
      String errorMsg = '';
      if (e is String) {
        errorMsg = e;
      } else {
        errorMsg = e.message;
      }
      ToastUtil.showToast($t('登录失败: ') + errorMsg, type: ToastType.error);
      throw e;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Widget loginButton(Color backgroundColor, String icon, String title,
      LoginPlatform platform, Color color) {
    return GestureDetector(
      onTapDown: (ev) {},
      onTap: () {
          login();
      },
      child: Container(
        width: 584.w,
        height: 110.w,
        margin: EdgeInsets.only(bottom: 50.w),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w), color: backgroundColor),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/login/" + icon,
                width: 30.w, height: 30.w, fit: BoxFit.cover),
            SizedBox(width: 20.w),
            Text(
              title,
              style: TextStyle(
                  color: color,
                  fontSize: SizeConstant.h7,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(left: 40.w, right: 40.w, top: 8.w),
      constraints: BoxConstraints(minHeight: 120.w),
      height: 120.w,
      decoration: BoxDecoration(
        color: Color(0xFFFDFFFF),
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: Colors.black),
      ),
      child: TextField(
        controller: textEditingController,
        onChanged: (value) {
          setState(() {});
        },
        expands: true,
        maxLines: null,
        minLines: null,
        scrollPadding: EdgeInsets.all(0),
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: ColorConstant.appBackground,
          fontSize: SizeConstant.h7,
          fontFamily: 'CarterOne-Regular',
          height: 1.25,
        ),
        decoration: InputDecoration(
          hintText: $t('请输入私钥'),
          contentPadding: EdgeInsets.only(left: 16.w, right: 16.w),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          hintStyle: TextStyle(
            color: ColorConstant.teamRuleText,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseWillPopScope(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: ColorConstant.appBackground,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildTextField(),
              SizedBox(height: 50.w),
            ],
          ),
        ),
      ),
    );
  }
}
