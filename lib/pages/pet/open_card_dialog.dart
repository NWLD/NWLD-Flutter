import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/pages/bottom-dialogs/bottom_dialog_container.dart';
import 'package:kingspro/widgets/flip.dart';
import 'package:kingspro/widgets/shadow_container.dart';

import '../../l10n/base_localizations.dart';

class OpenCardDialog extends StatefulWidget {
  final List<PetInfo> pets;

  OpenCardDialog({Key key, this.pets}) : super(key: key);

  @override
  _OpenCardState createState() => _OpenCardState();
}

class _OpenCardState extends State<OpenCardDialog>
    with BaseLocalizationsStateMixin {
  List _pets = <PetInfo>[];

  @override
  void initState() {
    _pets = widget.pets;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("恭喜获得"),
      content: GridView(
        padding: EdgeInsets.only(top: 0, bottom: 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 375 / 446,
        ),
        children: buildItems(),
        physics: AlwaysScrollableScrollPhysics(),
        cacheExtent: 1000,
      ),
    );
  }

  buildItems() {
    List<Widget> items = [];
    int len = _pets.length;
    for (int index = 0; index < len; index++) {
      items.add(
        Padding(
          padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
          child: buildItem(_pets[index], index),
        ),
      );
    }
    return items;
  }

  Widget buildItem(PetInfo heroInfo, int index) {
    return FlipWidget(
      key: ValueKey(index),
      front: _buildFront(),
      back: _buildRear(heroInfo),
      delay: 300 + index * 100,
    );
  }

  Widget _buildFront() {
    return ShadowContainer(
      width: 335.w,
      height: 426.w,
      color: ColorConstant.bg_level_9,
      key: ValueKey(true),
    );
  }

  Widget _buildRear(PetInfo heroInfo) {
    return ShadowContainer(
      width: 335.w,
      height: 426.w,
      color: heroInfo.rareBg(),
      padding: EdgeInsets.all(0),
      key: ValueKey(false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pet/pet_${heroInfo.who}.png',
            width: 200.w,
            height: 200.w,
          ),
          Text(
            $t('pet_${heroInfo.who}'),
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h8,
            ),
          ),
          SizedBox(
            height: 16.w,
          ),
          Text(
            heroInfo.rareLabel(),
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
            heroInfo.level.toString() + "星",
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
            heroInfo.getFight().toString() + " 战力",
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
}
