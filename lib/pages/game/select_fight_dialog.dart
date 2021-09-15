import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/FightPet.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/GameService.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

typedef OnFightHeroSelected = void Function(FightPet fightHero);

class FightHeroItem extends StatefulWidget {
  final int index;
  final FightPet fightHero;
  final OnFightHeroSelected onFightHeroSelected;

  FightHeroItem({
    this.index,
    this.fightHero,
    this.onFightHeroSelected,
  });

  @override
  State<FightHeroItem> createState() {
    return _FightHeroItemState();
  }
}

class _FightHeroItemState extends State<FightHeroItem>
    with BaseLocalizationsStateMixin {
  FightPet fightHero;

  @override
  void initState() {
    fightHero = widget.fightHero;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: () {
        widget.onFightHeroSelected(fightHero);
        Navigator.of(context).pop();
      },
      child: ShadowContainer(
        height: 200.w,
        color: fightHero.heroInfo.rareBg(),
        margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/pet/pet_${fightHero.heroInfo.who}.png',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.fill,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      $t('pet_${fightHero.heroInfo.who}'),
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
                      fightHero.heroInfo.rareLabel() +
                          " " +
                          fightHero.heroInfo.level.toString() +
                          "星 " +
                          fightHero.heroInfo.getFight().toString() +
                          " 战力",
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
                      $t(
                            '剩余次数',
                          ) +
                          " " +
                          fightHero.fightCount.toString() +
                          "  " +
                          $t(
                            '胜率',
                          ) +
                          " " +
                          fightHero.winRate.toString() +
                          '%',
                      style: TextStyle(
                        color: ColorConstant.title,
                        fontWeight: FontWeight.bold,
                        fontSize: SizeConstant.h8,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SelectFightHeroDialog extends StatefulWidget {
  final int difficulty;
  final OnFightHeroSelected onFightHeroSelected;

  SelectFightHeroDialog({
    Key key,
    this.difficulty = 1,
    this.onFightHeroSelected,
  }) : super(key: key);

  @override
  _SelectFightHeroDialogState createState() => _SelectFightHeroDialogState();
}

class _SelectFightHeroDialogState extends State<SelectFightHeroDialog>
    with BaseLocalizationsStateMixin {
  List<FightPet> _heroList = <FightPet>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getHeroList();
    super.initState();
  }

  void getHeroList() async {
    String config = ConfigConstants.game3;
    if (2 == widget.difficulty) {
      config = ConfigConstants.game2;
    } else if (1 == widget.difficulty) {
      config = ConfigConstants.game1;
    }
    String address = ConfigModel.getInstance().config(config);
    List<FightPet> heroes = await GameService(config, address).getFightPets();
    setState(() {
      _heroList = heroes;
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("选择卡牌"),
      content: ListView.builder(
        controller: _controller,
        itemCount: _heroList.length,
        itemBuilder: (context, index) {
          return FightHeroItem(
            index: index,
            fightHero: _heroList[index],
            onFightHeroSelected: widget.onFightHeroSelected,
          );
        },
      ),
    );
  }
}
