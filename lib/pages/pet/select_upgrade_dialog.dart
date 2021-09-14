import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

typedef OnPetSelected = void Function(PetInfo pet);

class PetItem extends StatefulWidget {
  final int index;
  final PetInfo petInfo;
  final OnPetSelected onPetSelected;

  PetItem({
    this.index,
    this.petInfo,
    this.onPetSelected,
  });

  @override
  State<PetItem> createState() {
    return _ItemState();
  }
}

class _ItemState extends State<PetItem> with BaseLocalizationsStateMixin {
  PetInfo _petInfo;

  @override
  void initState() {
    _petInfo = widget.petInfo;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TouchDownScale(
      onTap: () {
        widget.onPetSelected(_petInfo);
        Navigator.of(context).pop();
      },
      child: ShadowContainer(
        height: 200.w,
        color: _petInfo.rareBg(),
        margin: EdgeInsets.only(left: 40.w, right: 40.w, bottom: 40.w),
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/pet/pet_${_petInfo.who}.png',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.fill,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      $t('pet_${_petInfo.who}') +
                          " " +
                          _petInfo.rareLabel() +
                          " " +
                          _petInfo.level.toString() +
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
                      _petInfo.getFight().toString() + " 战力",
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
          ],
        ),
      ),
    );
  }
}

class SelectUpgradePetDialog extends StatefulWidget {
  final PetInfo petInfo;
  final OnPetSelected onPetSelected;

  SelectUpgradePetDialog({
    Key key,
    this.petInfo,
    this.onPetSelected,
  }) : super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<SelectUpgradePetDialog>
    with BaseLocalizationsStateMixin {
  List<PetInfo> _petList = <PetInfo>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getPetList();
    super.initState();
  }

  void getPetList() {
    List<PetInfo> pets = [];
    pets.addAll(AccountModel.getInstance().pets);
    List<PetInfo> list = [];
    for (int index = 0; index < pets.length; index++) {
      if (widget.petInfo.who == pets[index].who &&
          widget.petInfo.level == pets[index].level &&
          widget.petInfo.tokenId != pets[index].tokenId) {
        list.add(pets[index]);
      }
    }
    if (0 == list.length) {
      Future.delayed(
        Duration(
          milliseconds: 50,
        ),
        () {
          Navigator.of(context).pop();
          ToastUtil.showToast($t('没有可供选择的卡牌'), type: ToastType.warning);
        },
      );
      return;
    }
    _petList = list;
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
        itemCount: _petList.length,
        itemBuilder: (context, index) {
          return PetItem(
            index: index,
            petInfo: _petList[index],
            onPetSelected: widget.onPetSelected,
          );
        },
      ),
    );
  }
}
