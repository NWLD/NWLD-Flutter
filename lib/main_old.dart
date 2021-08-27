import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  String privateKey =
      '07d02cc5361b39ceaa024460030667a4e2fb14e762b389be5ade3a7beea8b089';
  String rpcUrl =
      'https://http-mainnet.hecochain.com'; //'https://pub001.hg.network/rpc';
  int chainId = 128;

  final EthereumAddress contractAddr =
      EthereumAddress.fromHex('0xFE6133e86fb4d5811f2e6881c2E25567B45b60B6');
  final EthereumAddress receiver =
      EthereumAddress.fromHex('0xC44F16045D94049284FE4E27ec8D46Ea4bE26560');

  void _incrementCounter() async {
    // await send();
    // await withContract();
    await buyHero();
    setState(() {
      _counter++;
    });
  }

  Future<void> send() async {
    // start a client we can use to send transactions
    final client = Web3Client(rpcUrl, Client());

    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final address = credentials.address;

    print(address.hexEip55);
    print(await client.getBalance(address));
    // final client =
    // Web3Client(SettingsModel().currentChainRpc(), Client());
    // print(await client.getBalance(address));
    int count = await client.getTransactionCount(credentials.address);
    print(count);

    String result = await client.sendTransaction(
      credentials,
      Transaction(
        to: EthereumAddress.fromHex(
            '0xC44F16045D94049284FE4E27ec8D46Ea4bE26560'),
        gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 3),
        maxGas: 100000,
        value: EtherAmount.fromUnitAndValue(EtherUnit.finney, 100),
        // nonce: count + 1,
      ),
      chainId: chainId,
    );
    print(result);
    await client.dispose();
  }

  withContract() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    final client = Web3Client(rpcUrl, Client());
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final ownAddress = await credentials.extractAddress();

    // read the contract abi and tell web3dart where it's deployed (contractAddr)
    final abiCode = await rootBundle.loadString('assets/abi/erc20.json');
    final contract =
        DeployedContract(ContractAbi.fromJson(abiCode, 'ERC20'), contractAddr);

    // extracting some functions and events that we'll need later
    final transferEvent = contract.event('Transfer');
    final balanceFunction = contract.function('balanceOf');
    final sendFunction = contract.function('transfer');
    final approveFunction = contract.function('approve');

    // listen for the Transfer event when it's emitted by the contract above
    final subscription = client
        .events(FilterOptions.events(contract: contract, event: transferEvent))
        .take(1)
        .listen((event) {
      final decoded = transferEvent.decodeResults(event.topics, event.data);

      final from = decoded[0] as EthereumAddress;
      final to = decoded[1] as EthereumAddress;
      final value = decoded[2] as BigInt;

      print('$from sent $value MetaCoins to $to');
    });

    // check our balance in MetaCoins by calling the appropriate function
    final balance = await client.call(
        contract: contract, function: balanceFunction, params: [ownAddress]);
    print('We have ${balance.first} MetaCoins');

    print('getGasPrice');
    print(await client.getGasPrice());

    // send all our MetaCoins to the other address by calling the sendCoin
    // function
    // await client.sendTransaction(
    //   credentials,
    //   Transaction.callContract(
    //     contract: contract,
    //     function: sendFunction,
    //     from: ownAddress,
    //     parameters: [receiver, balance.first],
    //     gasPrice: EtherAmount.fromUnitAndValue(EtherUnit.gwei, 3),
    //     maxGas: 1000000,
    //   ),
    //   chainId: 128,
    // );

    String hashId = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: approveFunction,
        parameters: [receiver, balance.first],
      ),
      chainId: 128,
    );

    print('hashId= $hashId');

    await subscription.asFuture();
    await subscription.cancel();

    await client.dispose();
  }

  buyHero() async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    final client = Web3Client(rpcUrl, Client());
    final credentials = await client.credentialsFromPrivateKey(privateKey);
    final ownAddress = await credentials.extractAddress();

    EthereumAddress tokenAddress =
        EthereumAddress.fromHex('0xFE6133e86fb4d5811f2e6881c2E25567B45b60B6');
    final tokenAbi = await rootBundle.loadString('assets/abi/erc20.json');
    final tokenContract =
        DeployedContract(ContractAbi.fromJson(tokenAbi, 'Token'), tokenAddress);
    //余额
    final balanceFunction = tokenContract.function('balanceOf');
    final balance = await client.call(
        contract: tokenContract,
        function: balanceFunction,
        params: [ownAddress]);
    print('We have ${balance.first} Token');
    //授权额度
    final allowFunction = tokenContract.function('allowance');
    EthereumAddress shopAddress =
        EthereumAddress.fromHex('0xFF43Aa8059C72Ce99665F69846799ef4Bda2FCd0');
    final allowance = await client.call(
        contract: tokenContract,
        function: allowFunction,
        params: [ownAddress, shopAddress]);
    print('We have ${allowance.first} allowance');
    //授权
    final approveFunction = tokenContract.function('approve');
    String approveHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: tokenContract,
        function: approveFunction,
        parameters: [shopAddress, balance.first],
      ),
      chainId: 128,
    );
    print('approveHash $approveHash');

    sleep(Duration(seconds: 10));
    //TODO 需要等待授权确认
    final allowanceAfter = await client.call(
        contract: tokenContract,
        function: allowFunction,
        params: [ownAddress, shopAddress]);
    print('We have ${allowanceAfter.first} allowanceAfter');

    final shopAbi = await rootBundle.loadString('assets/abi/shop.json');
    final shopContract =
        DeployedContract(ContractAbi.fromJson(shopAbi, 'Shop'), shopAddress);
    final buyFunction = shopContract.function('buy');
    String buyHash = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: shopContract,
        function: buyFunction,
        parameters: [],
        // maxGas: 1000000,
      ),
      chainId: 128,
    );
    print('buyHash= $buyHash');
    await client.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
