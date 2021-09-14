import 'package:kingspro/constants/config.dart';
import 'package:kingspro/util/number_util.dart';

class PetUpdateInfo {
  BigInt price;
  String rate;

  PetUpdateInfo(this.price, this.rate);

  String priceLabel() {
    return NumberUtil.decimalNumString(
            num: price.toString(), fractionDigits: 0) +
        ' ' +
        ConfigConstants.gameTokenSymbol;
  }
}
