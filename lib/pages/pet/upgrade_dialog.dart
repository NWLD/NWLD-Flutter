import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/sizes.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/pages/pet/upgrade1.dart';
import 'package:kingspro/pages/pet/upgrade2.dart';
import 'package:kingspro/widgets/shadow_container.dart';

import '../../l10n/base_localizations.dart';
import '../bottom-dialogs/bottom_dialog_container.dart';

class UpgradeDialog extends StatefulWidget {
  final PetInfo petInfo;

  UpgradeDialog({Key key, this.petInfo}) : super(key: key);

  @override
  _DialogState createState() => _DialogState();
}

class _DialogState extends State<UpgradeDialog>
    with BaseLocalizationsStateMixin {
  PetInfo _petInfo;

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    _petInfo = widget.petInfo;
    super.initState();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildCard(bool upgrade) {
    return ShadowContainer(
      width: 200.w,
      height: 300.w,
      color: _petInfo.rareBg(),
      padding: EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/pet/pet_${_petInfo.who}.png',
            width: 200.w,
            height: 200.w,
          ),
          Text(
            (upgrade ? _petInfo.level + 1 : _petInfo.level).toString() + "星",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConstant.h8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            (upgrade
                    ? _petInfo.upgradeFight().toString()
                    : _petInfo.getFight().toString()) +
                " " +
                $t("战力"),
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

  @override
  Widget build(BuildContext context) {
    return BottomDialogContainer(
      title: $t("升级"),
      content: ListView(
        controller: _controller,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildCard(false),
              Padding(
                padding: EdgeInsets.only(left: 40.w, right: 40.w),
                child: Text(
                  '-->',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h3,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              buildCard(true),
            ],
          ),
          SizedBox(
            height: 40.w,
          ),
          UpgradeItem1(
            petInfo: _petInfo,
          ),
          UpgradeItem2(
            petInfo: _petInfo,
          ),
        ],
      ),
    );
  }
}
