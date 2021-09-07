import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/service/HeroService.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import 'bottom_dialog_container.dart';

class HeroItem extends StatefulWidget {
  final int index;
  final HeroInfo heroInfo;

  HeroItem({
    this.index,
    this.heroInfo,
  });

  @override
  State<HeroItem> createState() {
    return _HeroItemState();
  }
}

class _HeroItemState extends State<HeroItem> with BaseLocalizationsStateMixin {
  HeroInfo heroInfo;

  @override
  void initState() {
    heroInfo = widget.heroInfo;
    HeroService.getHeroInfo(widget.heroInfo.tokenId);
    HeroService.getHeroFight(widget.heroInfo.tokenId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240.w,
      width: 600.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            "assets/game/bg_list_store.png",
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              children: [
                Text(
                  heroInfo.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h8,
                    fontFamily: "CarterOne-Regular",
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AssetsDialog extends StatefulWidget {
  @override
  _AssetsDialogState createState() => _AssetsDialogState();
}

class _AssetsDialogState extends State<AssetsDialog>
    with BaseLocalizationsStateMixin {
  List<HeroInfo> _heroList = <HeroInfo>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getHeroList();
    super.initState();
  }

  void getHeroList() async {
    List<BigInt> heroIds = await HeroService.getHeroIds(
      AccountModel.getInstance().account,
      10,
      0,
    );
    int len = heroIds.length;
    List<HeroInfo> heros = <HeroInfo>[];
    for (int index = 0; index < len; index++) {
      heros.add(HeroInfo.fromTokenId(heroIds[index]));
    }
    setState(() {
      _heroList = heros;
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
      title: $t("资产"),
      backgroundImagePath: "assets/game/bg_store.png",
      content: ListView.builder(
        controller: _controller,
        itemCount: _heroList.length,
        itemBuilder: (context, index) {
          return HeroItem(
            index: index,
            heroInfo: _heroList[index],
          );
        },
      ),
    );
  }
}
