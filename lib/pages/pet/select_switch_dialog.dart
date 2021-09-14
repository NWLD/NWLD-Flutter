import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/service/PetService.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/touch_down_scale.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

typedef OnWhoSelected = void Function(int who);

class PetItem extends StatefulWidget {
  final int index;
  final PetInfo petInfo;
  final int who;
  final OnWhoSelected onWhoSelected;

  PetItem({
    this.index,
    this.petInfo,
    this.who,
    this.onWhoSelected,
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
        widget.onWhoSelected(widget.who);
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
                  'assets/pet/pet_${widget.who}.png',
                  width: 200.w,
                  height: 200.w,
                  fit: BoxFit.fill,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      $t('pet_${widget.who}'),
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

class SelectSwitchRolePetDialog extends StatefulWidget {
  final PetInfo petInfo;
  final OnWhoSelected onWhoSelected;

  SelectSwitchRolePetDialog({
    Key key,
    this.petInfo,
    this.onWhoSelected,
  }) : super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<SelectSwitchRolePetDialog>
    with BaseLocalizationsStateMixin {
  List<int> _whoList = <int>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getPetList();
    super.initState();
  }

  void getPetList() async {
    List<int> intList = await PetService.getRareWhoList(widget.petInfo.rare);
    List<int> whoList = [];
    for (int index = 0; index < intList.length; index++) {
      if (widget.petInfo.who != intList[index] &&
          !whoList.contains(intList[index])) {
        whoList.add(intList[index]);
      }
    }
    setState(() {
      _whoList = whoList;
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
        itemCount: _whoList.length,
        itemBuilder: (context, index) {
          return PetItem(
            index: index,
            petInfo: widget.petInfo,
            who: _whoList[index],
            onWhoSelected: widget.onWhoSelected,
          );
        },
      ),
    );
  }
}
