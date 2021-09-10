import 'package:kingspro/entity/HeroInfo.dart';

class FightHero {
  HeroInfo heroInfo;
  int winRate;
  int fightCount;

  FightHero(this.heroInfo, this.fightCount, this.winRate);
}
