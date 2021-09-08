import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kingspro/constants/colors.dart';
import 'package:kingspro/constants/config.dart';
import 'package:kingspro/entity/HeroInfo.dart';
import 'package:kingspro/entity/ShopItem.dart';
import 'package:kingspro/models/account_model.dart';
import 'package:kingspro/models/config_model.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:kingspro/pages/bottom-dialogs/open_hero_dialog.dart';
import 'package:kingspro/util/PeriodicTimer.dart';
import 'package:kingspro/util/number_util.dart';
import 'package:kingspro/web3/ContractUtil.dart';
import 'package:kingspro/web3/Web3Util.dart';
import 'package:kingspro/widgets/TimerView.dart';
import 'package:kingspro/widgets/base_bottom_dialog.dart';
import 'package:kingspro/widgets/shadow_container.dart';
import 'package:kingspro/widgets/toast_util.dart';
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

import '../../constants/sizes.dart';
import '../../l10n/base_localizations.dart';
import '../../widgets/touch_down_scale.dart';
import 'bottom_dialog_container.dart';

class ShopItemWidget extends StatefulWidget {
  final int index;
  final String shopAddress;

  ShopItemWidget({
    this.index,
    this.shopAddress,
  });

  @override
  State<ShopItemWidget> createState() {
    return _ShopItemState();
  }
}

class _ShopItemState extends State<ShopItemWidget>
    with BaseLocalizationsStateMixin {
  EthereumAddress shopAddress;
  ShopItem _shopItem;

  @override
  void initState() {
    shopAddress = EthereumAddress.fromHex(widget.shopAddress);
    getShopItemInfo();
    super.initState();
  }

  void getShopItemInfo() async {
    final client = Web3Util().web3Client();
    DeployedContract shopContract =
        await ContractUtil().abiContract('shop', shopAddress.hex, 'Shop');
    ContractFunction shopInfoFunction = shopContract.function('shopInfo');
    List result = await client.call(
      contract: shopContract,
      function: shopInfoFunction,
      params: [],
    );
    ShopItem shopItem = ShopItem(
      nowTime: (result[0] as BigInt).toInt(),
      title: result[1].toString(),
      des: result[2].toString(),
      startTime: (result[3] as BigInt).toInt(),
      price: result[4] as BigInt,
      qty: (result[5] as BigInt).toInt(),
      soldCount: (result[6] as BigInt).toInt(),
    );
    setState(() {
      _shopItem = shopItem;
    });
    //定时刷新销售信息
    if (shopItem.startTime <= shopItem.nowTime &&
        shopItem.soldCount < shopItem.qty) {
      updateSaleInfo();
    }
  }

  buy(int num) async {
    try {
      EasyLoading.show();
      final client = Web3Util().web3Client();

      final credentials = await client
          .credentialsFromPrivateKey(AccountModel().decodePrivateKey());
      final ownAddress = await credentials.extractAddress();

      final gameTokenContract = await ContractUtil().gameTokenContract();
      //余额
      BigInt gameTokenBalance = AccountModel().gameTokenBalance;
      print('We have $gameTokenBalance Token');
      //余额不足
      if (null == gameTokenBalance ||
          gameTokenBalance < _shopItem.price * BigInt.from(num)) {
        ToastUtil.showToast(
          $t('余额不足'),
          type: ToastType.warning,
        );
        return;
      }
      //授权额度
      final allowFunction = gameTokenContract.function('allowance');
      final allowance = await client.call(
          contract: gameTokenContract,
          function: allowFunction,
          params: [ownAddress, shopAddress]);
      BigInt gameTokenAllowance = allowance.first;
      print('We have $gameTokenAllowance allowance');
      //授权足够，直接购买
      if (gameTokenAllowance >= _shopItem.price * BigInt.from(num)) {
        buyHero(credentials, ownAddress, num);
        return;
      }
      //需要授权
      final approveFunction = gameTokenContract.function('approve');
      //手续费价格
      print('getGasPrice');
      EtherAmount gasPrice = await client.getGasPrice();
      print(gasPrice);

      print('estimateGas');
      //TODO 账户余额不足会估算手续费失败
      Transaction transaction = Transaction.callContract(
        contract: gameTokenContract,
        function: approveFunction,
        from: ownAddress,
        gasPrice: gasPrice,
        parameters: [shopAddress, gameTokenBalance],
      );
      BigInt maxGas = await client.estimateGas(
        sender: transaction.from,
        to: transaction.to,
        data: transaction.data,
        value: transaction.value,
        gasPrice: transaction.gasPrice,
      );
      //1.1倍估算的gas，避免交易失败
      maxGas = maxGas * BigInt.from(110) ~/ BigInt.from(100);
      print(maxGas);

      print('gas');
      BigInt gas = maxGas * gasPrice.getInWei;
      print(gas);

      String approveHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: SettingsModel().currentChain().chainId,
      );
      print('approveHash $approveHash');

      PeriodicTimer timer = PeriodicTimer();
      timer.start(
        milliseconds: 3000,
        action: () async {
          TransactionReceipt transactionReceipt =
              await client.getTransactionReceipt(approveHash);
          //Pending
          if (null == transactionReceipt) {
            print('approve pending');
            return;
          }
          print(transactionReceipt);
          //交易成功，已授权，可以购买了
          if (transactionReceipt.status) {
            timer.cancel(false);
            buyHero(credentials, ownAddress, num);
            return;
          }
          //交易失败
          timer.cancel(false);
        },
        maxCount: 10,
        onEnd: (bool max) {
          //次数超过，导致周期性执行失败
          if (true == max) {
            return;
          }
          print('approve onEnd');
        },
      );
      await client.dispose();
    } catch (e) {
      ToastUtil.showToast(e.toString());
      EasyLoading.dismiss();
    } finally {}
  }

  void buyHero(credentials, ownAddress, int num) async {
    try {
      EasyLoading.show();
      final client = Web3Util().web3Client();
      final shopContract =
          await ContractUtil().abiContract('shop', shopAddress.hex, 'Shop');
      final buyFunction = shopContract.function('buy');
      final patchBuyFunction = shopContract.function('batchBuy');

      //手续费价格
      print('getGasPrice');
      EtherAmount gasPrice = await client.getGasPrice();
      print(gasPrice);

      print('estimateGas');
      //TODO 账户余额不足会估算手续费失败
      Transaction transaction = Transaction.callContract(
        contract: shopContract,
        function: 1 == num ? buyFunction : patchBuyFunction,
        from: ownAddress,
        gasPrice: gasPrice,
        parameters: 1 == num ? [] : [BigInt.from(num)],
      );
      BigInt maxGas = await client.estimateGas(
        sender: transaction.from,
        to: transaction.to,
        data: transaction.data,
        value: transaction.value,
        gasPrice: transaction.gasPrice,
      );
      //1.1倍估算的gas，避免交易失败
      maxGas = maxGas * BigInt.from(110) ~/ BigInt.from(100);
      print(maxGas);

      print('gas');
      BigInt gas = maxGas * gasPrice.getInWei;
      print(gas);

      String buyHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: SettingsModel().currentChain().chainId,
      );
      print('buyHash= $buyHash');
      PeriodicTimer timer = PeriodicTimer();
      timer.start(
        milliseconds: 3000,
        maxCount: 10,
        action: () async {
          TransactionReceipt transactionReceipt =
              await client.getTransactionReceipt(buyHash);
          //Pending
          if (null == transactionReceipt) {
            print('buy pending');
            return;
          }
          print(transactionReceipt);
          //购买成功，可以播放开卡动画了
          if (transactionReceipt.status) {
            timer.cancel(false);
            final heroContract = await ContractUtil().abiContract(
                'hero',
                ConfigModel.getInstance().config(ConfigConstants.heroNFT),
                'Hero');
            final tokensOfFunction = heroContract.function('tokensOf');
            List result = await client.call(
              contract: heroContract,
              function: tokensOfFunction,
              params: [ownAddress, BigInt.from(0), BigInt.from(0)],
            );
            List tokenIds = result[0] as List;
            List<HeroInfo> heroes = <HeroInfo>[];
            int len = tokenIds.length;
            for (int index = len - num; index < len; index++) {
              BigInt id = tokenIds[index] as BigInt;
              heroes.add(HeroInfo.fromTokenId(id));
            }
            //显示开卡动画
            BottomDialog.showDialog(
                context,
                OpenCardDialog(
                  heroes: heroes,
                ));
            return;
          }
          //交易失败
          timer.cancel(false);
        },
        onEnd: (bool max) {
          EasyLoading.dismiss();
          //次数超过，导致周期性执行失败
          if (true == max) {
            return;
          }
          print('buy onEnd');
        },
      );
      await client.dispose();
    } catch (e) {
      ToastUtil.showToast(e.toString());
      EasyLoading.dismiss();
    } finally {}
  }

  Widget buildBuyButton() {
    int seconds = _shopItem.startTime - _shopItem.nowTime;
    //未开始
    if (seconds > 0) {
      return TimerView(
        color: Colors.white,
        initSeconds: seconds,
        onCountdownEnd: () {
          setState(() {});
          updateSaleInfo();
        },
      );
    }
    //已卖光
    if (_shopItem.soldCount >= _shopItem.qty) {
      return Text(
        $t('已卖光'),
        style: TextStyle(
          color: Colors.white,
          fontSize: SizeConstant.h8,
        ),
      );
    }
    return Row(
      children: [
        TouchDownScale(
          onTapDown: (ev) {},
          onTap: () {
            buy(1);
          },
          child: ShadowContainer(
            width: 100.w,
            height: 48.w,
            color: ColorConstant.bg_level_4,
            child: Center(
              child: Text(
                $t('购买'),
                style: TextStyle(
                  color: ColorConstant.title,
                  fontSize: SizeConstant.h9,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 20.w,
        ),
        TouchDownScale(
          onTapDown: (ev) {},
          onTap: () {
            buy(10);
          },
          child: ShadowContainer(
            width: 100.w,
            height: 48.w,
            color: ColorConstant.bg_level_7,
            child: Center(
              child: Text(
                $t('10 连'),
                style: TextStyle(
                  color: ColorConstant.titleBg,
                  fontSize: SizeConstant.h8,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (null == _shopItem) {
      return Container();
    }
    return ShadowContainer(
      height: 240.w,
      margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 20.w),
      padding: EdgeInsets.all(20.w),
      color: ColorConstant.titleBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _shopItem.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: SizeConstant.h7,
                  ),
                ),
              ),
              SizedBox(width: 20.w),
              Text(
                '${_shopItem.soldCount}/${_shopItem.qty}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConstant.h7,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          Text(
            _shopItem.des,
            style: TextStyle(
              color: ColorConstant.des,
              fontSize: SizeConstant.h9,
            ),
          ),
          Expanded(child: Container()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                NumberUtil.decimalNumString(
                      num: _shopItem.price.toString(),
                      fractionDigits: 0,
                    ) +
                    ' ' +
                    ConfigModel.getInstance()
                        .config(ConfigConstants.gameTokenSymbol),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: SizeConstant.h7,
                ),
              ),
              Expanded(child: Container()),
              buildBuyButton(),
            ],
          ),
        ],
      ),
    );
  }

  void updateSaleInfo() {
    if (null != _periodicTimer) {
      return;
    }
    _periodicTimer = PeriodicTimer();
    _periodicTimer.start(
      milliseconds: 3000,
      maxCount: 100000,
      action: () {
        getShopItemInfo();
      },
      onEnd: (max) {},
    );
  }

  PeriodicTimer _periodicTimer;

  @override
  void dispose() {
    if (null != _periodicTimer) {
      _periodicTimer.cancel(false);
      _periodicTimer = null;
    }
    super.dispose();
  }
}

class ShopDialog extends StatefulWidget {
  @override
  _ShopDialogState createState() => _ShopDialogState();
}

class _ShopDialogState extends State<ShopDialog>
    with BaseLocalizationsStateMixin {
  List shopAddressList = <String>[];

  ScrollController _controller = ScrollController(
    keepScrollOffset: true,
  );

  @override
  void initState() {
    getItems();
    super.initState();
  }

  void getItems() async {
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        shopAddressList = [
          ConfigModel.getInstance().config(ConfigConstants.heroShop),
        ];
      });
    });
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountModel>(builder: (context, accountModel, child) {
      return BottomDialogContainer(
        title: $t("礼包"),
        content: ListView.builder(
          controller: _controller,
          itemCount: shopAddressList.length,
          itemBuilder: (context, index) {
            return ShopItemWidget(
              index: index,
              shopAddress: shopAddressList[index],
            );
          },
        ),
      );
    });
  }
}
