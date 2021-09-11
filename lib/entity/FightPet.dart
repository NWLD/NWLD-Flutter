import 'package:kingspro/entity/PetInfo.dart';

class FightPet {
  PetInfo heroInfo;
  int winRate;
  int fightCount;

  FightPet(this.heroInfo, this.fightCount, this.winRate);
}
