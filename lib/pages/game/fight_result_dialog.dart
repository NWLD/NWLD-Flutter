import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/FightReward.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/pages/bottom-dialogs/bottom_dialog_container.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/widgets/flip.dart';
import 'package:kingspro/widgets/shadow_container.dart';

import '../../l10n/base_localizations.dart';

class FightResultDialog extends StatefulWidget {
  final List<int> results;
  final FightReward fightReward;

  FightResultDialog({Key key, this.results, this.fightReward})
      : super(key: key);

  @override
  _FightResultDialogState createState() => _FightResultDialogState();
}

class _FightResultDialogState extends State<FightResultDialog>
    with BaseLocalizationsStateMixin {
  List _results = <int>[];
  FightReward _fightReward;

  @override
  void initState() {
    _results = widget.results;
    _fightReward = widget.fightReward;
    super.initState();
  }

  String getWinToken() {
    BigInt win = BigInt.from(0);
    for (int index = 0; index < _results.length; index++) {
      if (1 == _results[index]) {
        win += _fightReward.token;
      }
    }
    return NumberUtil.decimalNumString(num: win.toString(), fractionDigits: 0);
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("战斗结果"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '+ ' + getWinToken() + ' ' + ConfigConstants.gameTokenSymbol,
            style: TextStyle(
              color: ColorConstant.title,
              fontSize: SizeConstant.h7,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10.w,
          ),
          Text(
            '+ ' +
                (_fightReward.exp * BigInt.from(_results.length)).toString() +
                ' exp',
            style: TextStyle(
              color: ColorConstant.title,
              fontSize: SizeConstant.h7,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 40.w,
          ),
          Expanded(
            child: GridView(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 250 / 130,
              ),
              children: buildItems(),
              physics: AlwaysScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }

  buildItems() {
    List<Widget> items = [];
    int len = _results.length;
    for (int index = 0; index < len; index++) {
      items.add(
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
          child: buildItem(_results[index], index),
        ),
      );
    }
    return items;
  }

  Widget buildItem(int result, int index) {
    return FlipWidget(
      key: ValueKey(index),
      front: _buildFront(),
      back: _buildRear(result),
      delay: 300 + index * 100,
    );
  }

  Widget _buildFront() {
    return ShadowContainer(
      width: 210.w,
      height: 110.w,
      color: ColorConstant.bg_level_9,
      key: ValueKey(true),
    );
  }

  Widget _buildRear(int result) {
    return ShadowContainer(
      width: 210.w,
      height: 110.w,
      color: result == 1 ? ColorConstant.titleBg : ColorConstant.bg_level_3,
      padding: EdgeInsets.all(0),
      key: ValueKey(false),
      child: Center(
        child: Text(
          $t(1 == result ? '胜利' : '失败'),
          style: TextStyle(
            color: result == 1 ? ColorConstant.title : ColorConstant.bg_level_9,
            fontSize: SizeConstant.h7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
