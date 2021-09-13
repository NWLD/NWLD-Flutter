import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

class ContractUtil {
  static Future<DeployedContract> abiContract(
    String fileName,
    String contractAddress,
    String name,
  ) async {
    final abiCode = await rootBundle.loadString('assets/abi/$fileName.json');
    final EthereumAddress address = EthereumAddress.fromHex(contractAddress);
    final contract =
        DeployedContract(ContractAbi.fromJson(abiCode, name), address);
    return contract;
  }

  static ContractFunction functionOf(
    DeployedContract contract,
    String functionName,
  ) {
    return contract.function(functionName);
  }

  static Future<DeployedContract> erc20Contract(
    String address,
    String symbol,
  ) async {
    final contract = await abiContract('erc20', address, symbol);
    return contract;
  }
}
