import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:kingspro/web3/Web3Util.dart';
import 'package:web3dart/web3dart.dart';

class TokenUtil {
  static Future<BigInt> getBalance(String account) async {
    if (StringUtils.isEmpty(account)) {
      return BigInt.from(0);
    }
    final client = Web3Util().web3Client();
    final EthereumAddress address = EthereumAddress.fromHex(account);
    EtherAmount balance = await client.getBalance(address);
    return balance.getInWei;
  }

  static Future<BigInt> getERC20Balance(
      String account, String contractAddress, String name) async {
    if (StringUtils.isEmpty(account) || StringUtils.isEmpty(contractAddress)) {
      return BigInt.from(0);
    }
    final client = Web3Util().web3Client();
    final EthereumAddress address = EthereumAddress.fromHex(account);
    final contract =
        await ContractUtil().abiContract('erc20', contractAddress, name);
    final balanceFunction = contract.function('balanceOf');
    final balance = await client
        .call(contract: contract, function: balanceFunction, params: [address]);
    return balance.first;
  }
}
