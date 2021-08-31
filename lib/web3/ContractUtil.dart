import 'package:flutter/services.dart';
import 'package:kingspro/constants/chain.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:web3dart/web3dart.dart';

class ContractUtil {
  Future<DeployedContract> abiContract(
      String json, String contractAddress, String name) async {
    final abiCode = await rootBundle.loadString('assets/abi/$json.json');
    final EthereumAddress address = EthereumAddress.fromHex(contractAddress);
    final contract =
        DeployedContract(ContractAbi.fromJson(abiCode, name), address);
    return contract;
  }

  Future<DeployedContract> erc20Contract(String address, String symbol) async {
    final contract = await ContractUtil().abiContract('erc20', address, symbol);
    return contract;
  }

  Future<DeployedContract> gameTokenContract() async {
    Chain chain = SettingsModel().currentChain();
    final contract = await ContractUtil()
        .erc20Contract(chain.gameTokenAddress, chain.gameTokenSymbol);
    return contract;
  }

  Future<ContractFunction> functionOf({
    String json,
    String contractAddress,
    String name,
    String functionName,
  }) async {
    DeployedContract contract = await abiContract(json, contractAddress, name);
    return contract.function(functionName);
  }
}
