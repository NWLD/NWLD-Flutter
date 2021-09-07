import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/pages/bottom-dialogs/bottom_dialog_container.dart';
import 'package:kingspro/widgets/flip.dart';
import 'package:kingspro/widgets/image.dart';

import '../../l10n/base_localizations.dart';

class OpenCardDialog extends StatefulWidget {
  final List<HeroInfo> heroes;

  OpenCardDialog({Key key, this.heroes}) : super(key: key);

  @override
  _OpenCardState createState() => _OpenCardState();
}

class _OpenCardState extends State<OpenCardDialog>
    with BaseLocalizationsStateMixin {
  List _heroes = <HeroInfo>[];

  @override
  void initState() {
    _heroes = widget.heroes;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("恭喜获得"),
      backgroundImagePath: "assets/game/bg_store.png",
      content: GridView(
        padding: EdgeInsets.only(top: 0, bottom: 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, //每行2个//纵轴(水平)方向间距
            childAspectRatio: 250 / 325 //纵轴缩���比例
            ),
        children: buildItems(),
        physics: AlwaysScrollableScrollPhysics(),
        cacheExtent: 1000,
      ),
    );
  }

  buildItems() {
    List<Widget> items = [];
    int len = _heroes.length;
    for (int index = 0; index < len; index++) {
      items.add(
        Padding(
          padding: EdgeInsets.all(20.w),
          child: buildItem(_heroes[index], index),
        ),
      );
    }
    return items;
  }

  Widget buildItem(HeroInfo heroInfo, int index) {
    return FlipWidget(
      key: ValueKey(index),
      front: _buildFront(),
      back: _buildRear(heroInfo),
      delay: 300 + index * 100,
    );
  }

  Widget _buildFront() {
    return ClipImage(
      key: ValueKey(true),
      width: 250.w,
      height: 325.w,
      radius: 20.w,
      boxColor: Colors.transparent,
      url: 'assets/card/card_back.webp',
    );
  }

  Widget _buildRear(HeroInfo heroInfo) {
    return Container(
      width: 250.w,
      height: 325.w,
      decoration: BoxDecoration(
        color: heroInfo.rareBg(),
        borderRadius: BorderRadius.circular(20.w),
      ),
      key: ValueKey(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/hero/hero_${heroInfo.who}.png',
            width: 160.w,
            height: 160.w,
          ),
          Text(
            $t('hero_${heroInfo.who}'),
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h9,
              fontFamily: "CarterOne-Regular",
            ),
          ),
          SizedBox(
            height: 6.w,
          ),
          Text(
            heroInfo.rareLabel(),
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h9,
              fontFamily: "CarterOne-Regular",
            ),
          ),
          SizedBox(
            height: 6.w,
          ),
          Text(
            heroInfo.level.toString() + "星",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h9,
              fontFamily: "CarterOne-Regular",
            ),
          ),
          SizedBox(
            height: 6.w,
          ),
          Text(
            "战力加成" + heroInfo.buffer.toString() + "%",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h9,
              fontFamily: "CarterOne-Regular",
            ),
          ),
        ],
      ),
    );
  }
}
