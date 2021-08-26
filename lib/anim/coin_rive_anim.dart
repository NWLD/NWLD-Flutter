import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

///金币动画
class CoinRiveAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CoinRiveAnimationState();
  }
}

class _CoinRiveAnimationState extends State<CoinRiveAnimation> {
  final riveFileName = 'assets/riv/get_coins.riv';
  Artboard _artBoard;
  RiveAnimationController _riveController;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile.import(bytes);

    final artBoard = file.mainArtboard;
    // get_coins
    _riveController = SimpleAnimation('get_coins');
    _riveController.isActiveChanged.addListener(() {
      Future.delayed(Duration(milliseconds: 30), () {
        if (!mounted) {
          return;
        }
        setState(() {
          if (_riveController.isActive) {
            // print('Animation started playing');
          } else {
            // print('Animation stopped playing');
          }
        });
      });
    });
    artBoard.addController(_riveController);
    setState(() {
      _artBoard = artBoard;
    });
  }

  @override
  void dispose() {
    _riveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _artBoard != null
        ? Rive(
            artboard: _artBoard,
            fit: BoxFit.cover,
          )
        : Container();
  }
}
