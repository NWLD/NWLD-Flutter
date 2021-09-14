import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/service/TransactionService.dart';
import 'package:kingspro/util/log_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetService {
  static Future<DeployedContract> petContract() async {
    final contract = await ContractUtil.abiContract(
        'pet', ConfigModel.getInstance().config(ConfigConstants.petNFT), 'Pet');
    return contract;
  }

  static Future<List<PetInfo>> getPets(
    String account,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await petContract();
    final tokensOfFunction = heroContract.function('tokensOf');
    List result = await client.call(
      contract: heroContract,
      function: tokensOfFunction,
      params: [EthereumAddress.fromHex(account)],
    );
    List tokenIds = result[0] as List;
    LogUtil.log('getPets', tokenIds);
    List<PetInfo> pets = <PetInfo>[];
    int len = tokenIds.length;
    for (int index = 0; index < len; index++) {
      pets.add(PetInfo.fromTokenId(tokenIds[index] as BigInt));
    }
    return pets;
  }

  static Future<bool> isApprovedForAll(String address) async {
    final client = Web3Util().web3Client();
    final contract = await petContract();
    final function = contract.function('isApprovedForAll');
    EthereumAddress ownAddress =
        EthereumAddress.fromHex(AccountModel.getInstance().account);

    List result = await client.call(
      contract: contract,
      function: function,
      params: [ownAddress, EthereumAddress.fromHex(address)],
    );
    return result[0] as bool;
  }

  static Future<String> ownerOf(BigInt tokenId) async {
    final client = Web3Util().web3Client();
    final contract = await petContract();
    final function = contract.function('ownerOf');

    List result = await client.call(
      contract: contract,
      function: function,
      params: [tokenId],
    );
    return (result[0] as EthereumAddress).hexEip55;
  }

  static Future<Transaction> approveAll(String address) async {
    final contract = await petContract();
    final function = contract.function('setApprovalForAll');
    return TransactionService.contractTransaction(
      contract,
      function,
      [EthereumAddress.fromHex(address), true],
    );
  }
}
