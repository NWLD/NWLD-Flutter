import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/pages/bottom-dialogs/bottom_dialog_container.dart';
import 'package:kingspro/widgets/flip.dart';
import 'package:kingspro/widgets/image.dart';

import '../../l10n/base_localizations.dart';

class OpenCardDialog extends StatefulWidget {
  final List<BigInt> tokenIds;

  OpenCardDialog({Key key, this.tokenIds}) : super(key: key);

  @override
  _OpenCardState createState() => _OpenCardState();
}

class _OpenCardState extends State<OpenCardDialog>
    with BaseLocalizationsStateMixin {
  List _heros = <HeroInfo>[];

  @override
  void initState() {
    initHeros();
    super.initState();
  }

  void initHeros() {
    int len = widget.tokenIds.length;
    List heros = <HeroInfo>[];
    for (int index = 0; index < len; index++) {
      heros.add(null);
    }
    _heros = heros;
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("恭喜获得"),
      backgroundImagePath: "assets/game/bg_store.png",
      content: 1 == _heros.length
          ? buildItem(_heros[0], 0)
          : GridView(
              padding: EdgeInsets.only(top: 0, bottom: 0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, //每行4个//纵轴(水平)方向间距
                  childAspectRatio: 250 / 325 //纵轴缩���比例
                  ),
              children: buildItems(),
              physics: AlwaysScrollableScrollPhysics(), //禁止滚动
            ),
    );
  }

  buildItems() {
    List<Widget> items = [];
    int len = _heros.length;
    for (int index = 0; index < len; index++) {
      items.add(
        Padding(
          padding: EdgeInsets.all(20.w),
          child: buildItem(_heros[index], index),
        ),
      );
    }
    return items;
  }

  Widget buildItem(HeroInfo heroInfo, int index) {
    return FlipWidget(
      front: _buildFront(),
      back: _buildRear(),
      delay: 300 + index * 100,
    );
  }

  Widget _buildFront() {
    return ClipImage(
      key: ValueKey(true),
      width: 250,
      height: 325,
      radius: 20,
      boxColor: Colors.transparent,
      url: 'assets/card/card_back.webp',
    );
  }

  Widget _buildRear() {
    return ClipImage(
      key: ValueKey(false),
      width: 250,
      height: 325,
      radius: 20,
      boxColor: Colors.transparent,
      url: 'assets/card/card_1.jpg',
      fit: BoxFit.fitHeight,
    );
  }
}
