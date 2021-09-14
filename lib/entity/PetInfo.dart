import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kingspro/constants/colors.dart';

class PetInfo {
  static int baseFight = 1000;

  // nftSign  custom  buffer   label  who    level   rarity    mintTime   index
  // 1        120     8        16     16     8       8         40         32
  // 255      128     120      104    88     80      72        32         0
  static BigInt CUSTOM = BigInt.from(0x00FFFFFFFFFF) << 128 |
      BigInt.from(0x00FFFFFFFFFF) << 168 |
      BigInt.from(0x00FFFFFFFFFF) << 208;
  static BigInt BUFFER = BigInt.from(0x00FF) << 120;
  static BigInt LABEL = BigInt.from(0x00FFFF) << 104;
  static BigInt WHO = BigInt.from(0x00FFFF) << 88;
  static BigInt LEVEL = BigInt.from(0x00FF) << 80;
  static BigInt RARE = BigInt.from(0x00FF) << 72;
  static BigInt TIME = BigInt.from(0x00FFFFFFFFFF) << 32;
  static BigInt NO = BigInt.from(0x00FFFFFFFF);

  PetInfo();

  BigInt tokenId;
  BigInt custom;
  int buffer;
  int label;
  int who;
  int level;
  int rare;
  int time;
  int no;

  // nftSign  custom  buffer   label  who    level   rarity    mintTime   index
  // 1        120     8        16     16     8       8         40         32
  // 255      128     120      104    88     80      72        32         0
  PetInfo.fromTokenId(BigInt tokenId) {
    this.tokenId = tokenId;
    this.custom = (tokenId & CUSTOM) >> 128;
    this.buffer = ((tokenId & BUFFER) >> 120).toInt();
    this.label = ((tokenId & LABEL) >> 104).toInt();
    this.who = ((tokenId & WHO) >> 88).toInt();
    this.level = ((tokenId & LEVEL) >> 80).toInt();
    this.rare = ((tokenId & RARE) >> 72).toInt();
    this.time = ((tokenId & TIME) >> 32).toInt();
    this.no = (tokenId & NO).toInt();
  }

  PetInfo.fromListData(BigInt tokenId, List<dynamic> list) {
    this.tokenId = tokenId;
    this.custom = list[0] as BigInt;
    this.buffer = (list[1] as BigInt).toInt();
    this.label = (list[2] as BigInt).toInt();
    this.who = (list[3] as BigInt).toInt();
    this.level = (list[4] as BigInt).toInt();
    this.rare = (list[5] as BigInt).toInt();
    // this.time = (list[6] as BigInt).toInt();
    this.no = (list[6] as BigInt).toInt();
  }

  String rareLabel() {
    switch (rare) {
      case 1:
        return 'N';
      case 2:
        return 'R';
      case 3:
        return 'SR';
      case 4:
        return 'SSR';
      case 5:
        return 'UR';
      case 6:
        return 'EX';
      default:
        return 'UN';
    }
  }

  Color rareBg() {
    switch (rare) {
      case 1:
        return ColorConstant.bg_level_3;
      case 2:
        return ColorConstant.bg_level_4;
      case 3:
        return ColorConstant.bg_level_5;
      case 4:
        return ColorConstant.bg_level_6;
      case 5:
        return ColorConstant.bg_level_7;
      case 6:
        return ColorConstant.bg_level_8;
      default:
        return ColorConstant.bg_level_1;
    }
  }

  int getRareBuffer() {
    switch (rare) {
      case 1:
        return 100;
      case 2:
        return 120;
      case 3:
        return 150;
      case 4:
        return 200;
      case 5:
        return 400;
      case 6:
        return 800;
      default:
        return 100;
    }
  }

  int getFight() {
    num fight = baseFight *
        (100 + buffer) *
        pow(2, level - 1) *
        getRareBuffer() /
        10000;
    return BigInt.from(fight).toInt();
  }

  int upgradeFight() {
    num fight =
        baseFight * (100 + buffer) * pow(2, level) * getRareBuffer() / 10000;
    return BigInt.from(fight).toInt();
  }

  @override
  String toString() {
    return 'tokenId = $tokenId\n' +
        'custom = $custom, ' +
        'buffer = $buffer, ' +
        'label = $label, ' +
        'who = $who, ' +
        'level = $level, ' +
        'rare = $rare, ' +
        'time = $time, ' +
        'no = $no';
  }
}
