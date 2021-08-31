import 'package:kingspro/util/log_util.dart';

class HeroInfo {
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

  HeroInfo();

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
  HeroInfo.fromTokenId(BigInt tokenId) {
    this.tokenId = tokenId;
    this.custom = (tokenId & CUSTOM) >> 128;
    this.buffer = ((tokenId & BUFFER) >> 120).toInt();
    this.label = ((tokenId & LABEL) >> 104).toInt();
    this.who = ((tokenId & WHO) >> 88).toInt();
    this.level = ((tokenId & LEVEL) >> 80).toInt();
    this.rare = ((tokenId & RARE) >> 72).toInt();
    this.time = ((tokenId & TIME) >> 32).toInt();
    this.no = (tokenId & NO).toInt();
    LogUtil.log('fromTokenId', tokenId);
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
