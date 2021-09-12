import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/PetInfo.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:web3dart/web3dart.dart';

import '../web3/Web3Util.dart';

class PetService {
  static Future<List<PetInfo>> getPets(
    String account,
  ) async {
    final client = Web3Util().web3Client();
    final heroContract = await ContractUtil().abiContract(
        'pet', ConfigModel.getInstance().config(ConfigConstants.petNFT), 'Pet');
    final tokensOfFunction = heroContract.function('tokensOf');
    List result = await client.call(
      contract: heroContract,
      function: tokensOfFunction,
      params: [EthereumAddress.fromHex(account)],
    );
    List tokenIds = result[0] as List;
    List<PetInfo> pets = <PetInfo>[];
    int len = tokenIds.length;
    for (int index = 0; index < len; index++) {
      pets.add(PetInfo.fromTokenId(tokenIds[index] as BigInt));
    }
    return pets;
  }
}
