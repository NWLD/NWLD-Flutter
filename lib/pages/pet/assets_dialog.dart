import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/pages/pet/upgrade_dialog.dart';
import 'package:kingspro/service/PetService.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

class HeroItem extends StatefulWidget {
  final int index;
  final PetInfo heroInfo;
  final Function onItemChanged;

  HeroItem({
    this.index,
    this.heroInfo,
    this.onItemChanged,
  });

  @override
  State<HeroItem> createState() {
    return _HeroItemState();
  }
}

class _HeroItemState extends State<HeroItem> with BaseLocalizationsStateMixin {
  PetInfo heroInfo;

  @override
  void initState() {
    heroInfo = widget.heroInfo;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HeroItem oldWidget) {
    heroInfo = widget.heroInfo;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return ShadowContainer(
      height: 260.w,
      color: heroInfo.rareBg(),
      margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                'assets/pet/pet_${heroInfo.who}.png',
                width: 200.w,
                height: 200.w,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    $t('pet_${heroInfo.who}'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: SizeConstant.h8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: 10.w,
                  ),
                  Text(
                    heroInfo.rareLabel() +
                        " " +
                        heroInfo.level.toString() +
                        "星",
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
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 40.w,
              ),
              TouchDownScale(
                onTapDown: (ev) {},
                onTap: upgrade,
                child: ShadowContainer(
                  width: 100.w,
                  height: 48.w,
                  color: ColorConstant.bg_level_4,
                  child: Center(
                    child: Text(
                      $t('升级'),
                      style: TextStyle(
                        color: ColorConstant.title,
                        fontSize: SizeConstant.h9,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40.w,
              ),
              TouchDownScale(
                onTapDown: (ev) {},
                onTap: () {},
                child: ShadowContainer(
                  width: 100.w,
                  height: 48.w,
                  color: ColorConstant.bg_level_7,
                  child: Center(
                    child: Text(
                      $t('变身'),
                      style: TextStyle(
                        color: ColorConstant.titleBg,
                        fontSize: SizeConstant.h8,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void upgrade() async {
    var result = await BottomDialog.showDialog(
      context,
      UpgradeDialog(
        petInfo: heroInfo,
      ),
    );
    if (null != result) {
      widget.onItemChanged();
    }
  }
}

class AssetsDialog extends StatefulWidget {
  @override
  _AssetsDialogState createState() => _AssetsDialogState();
}

class _AssetsDialogState extends State<AssetsDialog>
    with BaseLocalizationsStateMixin {
  List<PetInfo> _petList = <PetInfo>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getHeroList();
    super.initState();
  }

  void getHeroList() async {
    EasyLoading.show(dismissOnTap: true);
    try {
      List<PetInfo> pets =
          await PetService.getPets(AccountModel.getInstance().account);
      setState(() {
        _petList = pets;
      });
      AccountModel.getInstance().pets = pets;
    } catch (e) {
      ToastUtil.showToast(e.toString(), type: ToastType.error);
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onItemChanged() {
    getHeroList();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("资产"),
      content: ListView.builder(
        controller: _controller,
        itemCount: _petList.length,
        itemBuilder: (context, index) {
          return HeroItem(
            index: index,
            heroInfo: _petList[index],
            onItemChanged: onItemChanged,
          );
        },
      ),
    );
  }
}
