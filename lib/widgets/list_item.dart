import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';
import '../l10n/base_localizations.dart';

class AmountTypeItem extends StatelessWidget {
  final String type;
  final String time;
  final String amount;
  final String des;
  final Color amountColor;

  AmountTypeItem({
    Key key,
    @required this.type,
    @required this.amount,
    @required this.time,
    @required this.des,
    this.amountColor = ColorConstant.appBackground,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(left: 32.w, right: 32.w, top: 20.w, bottom: 20.w),
      margin: EdgeInsets.only(bottom: 24.w),
      decoration: BoxDecoration(
        color: ColorConstant.listItemBackground,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(
          color: Color(0xFF000000),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 类型
              Expanded(
                child: Text(
                  type ?? "",
                  style: TextStyle(
                    height: 1.5,
                    color: ColorConstant.teamLevelHeader,
                    fontSize: SizeConstant.h8,
                    fontFamily: 'CarterOne-Regular',
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              // 金额
              Text(
                amount,
                style: TextStyle(
                  height: 1.5,
                  fontSize: SizeConstant.h8,
                  color: amountColor,
                  fontFamily: 'CarterOne-Regular',
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
          Row(
            children: [
              //日期
              Text(
                time, // time ?? "",
                style: TextStyle(
                  height: 1.5,
                  color: ColorConstant.teamRuleText,
                  fontSize: SizeConstant.h10,
                  fontFamily: 'CarterOne-Regular',
                ),
              ),
              SizedBox(width: 24.w),
              // 描述
              Expanded(
                child: Text(
                  des ?? "",
                  style: TextStyle(
                    height: 1.5,
                    color: ColorConstant.teamRuleText,
                    fontSize: SizeConstant.h10,
                    fontFamily: 'CarterOne-Regular',
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NoMoreDataItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 60.w, top: 24.w),
      child: Text(
        BaseLocalizations.$t('没有更多数据了', context),
        style: TextStyle(
          height: 1.5,
          color: ColorConstant.des,
          fontSize: SizeConstant.h10,
          fontFamily: 'CarterOne-Regular',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class EmptyList extends StatelessWidget {
  final String icon;

  EmptyList({Key key, this.icon = 'assets/common/ic_no_record.png'})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: 60.w, right: 60.w, bottom: 120.w),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            icon,
            width: 144.w,
            height: 144.w,
          ),
          SizedBox(height: 48.w),
          Text(
            BaseLocalizations.$t('暂无记录', context),
            style: TextStyle(
              height: 1.5,
              color: ColorConstant.teamRuleText,
              fontSize: SizeConstant.h9,
              fontFamily: 'CarterOne-Regular',
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
