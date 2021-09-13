import 'package:kingspro/util/number_util.dart';
import 'package:web3dart/web3dart.dart';

class TransactionInfo {
  Transaction transaction;
  String value;

  TransactionInfo(this.transaction, this.value);

  String gasLabel() {
    BigInt gas =
        BigInt.from(transaction.maxGas) * transaction.gasPrice.getInWei;
    return NumberUtil.decimalNumString(
      num: gas.toString(),
      fractionDigits: 6,
    );
  }

  String gasDetail() {
    return 'Gas(' +
        transaction.maxGas.toString() +
        ') * ' +
        'Gas Price(' +
        NumberUtil.decimalNumString(
          num: transaction.gasPrice.getInWei.toString(),
          decimals: '9',
          fractionDigits: 2,
        ) +
        ' Gwei)';
  }
}
