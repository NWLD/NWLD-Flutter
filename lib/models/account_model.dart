import 'package:flutter/material.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/chain.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/util/aes_util.dart';
import 'package:kingspro/util/string_util.dart';
import 'package:kingspro/web3/TokenUtil.dart';

import '../util/cache_util.dart';

class AccountModel extends ChangeNotifier {
  static AccountModel _instance;

  static AccountModel getInstance() {
    if (_instance == null) {
      _instance = AccountModel.internal();
    }

    return _instance;
  }

  factory AccountModel() => getInstance();

  AccountModel.internal() {
    init();
  }

  String account;
  String name;
  String privateKey;
  BigInt balance;
  BigInt gameTokenBalance;

  init() {
    Map<String, dynamic> cachedData = CacheUtil.getData(CacheKey.account);
    if (cachedData != null) {
      name = cachedData['name'];
      privateKey = cachedData['privateKey'];
      account = cachedData['account'];
    }
    getBalance();
  }

  saveState() {
    final data = {
      'name': name,
      'privateKey': privateKey,
      'account': account,
    };
    CacheUtil.setData(CacheKey.account, data);
  }

  onStateChanged() {
    notifyListeners();
    saveState();
  }

  updateAccount({String account, String name, String privateKey}) {
    this.account = account;
    this.name = name;
    this.privateKey = privateKey;
    onStateChanged();
    getBalance();
  }

  String encodePrivateKey(String privateKey) {
    String pwd = SettingsModel().getPwd();
    String key = pwd + pwd + pwd + pwd;
    return AESUtil.encodeBase64(privateKey, key, key);
  }

  String decodePrivateKey() {
    String pwd = SettingsModel().getPwd();
    String key = pwd + pwd + pwd + pwd;
    return AESUtil.decodeBase64(privateKey, key, key);
  }

  bool isNull() {
    return StringUtils.isEmpty(account);
  }

  void getBalance() async {
    balance = await TokenUtil.getBalance(account);
    Chain chain = SettingsModel().currentChain();
    gameTokenBalance = await TokenUtil.getERC20Balance(
      account,
      ConfigModel.getInstance().config(ConfigConstants.gameToken),
      ConfigModel.getInstance().config(ConfigConstants.gameTokenSymbol),
    );
    notifyListeners();
  }
}
