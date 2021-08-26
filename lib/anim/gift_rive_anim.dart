import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

class LoopAnimation extends SimpleAnimation {
  LoopAnimation(String animationName) : super(animationName);

  start() {
    instance.animation.loop = Loop.loop;
    isActive = true;
  }

  stop() => instance.animation.loop = Loop.oneShot;
}

///礼盒动画
class GiftRiveAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GiftRiveAnimationState();
  }
}

class _GiftRiveAnimationState extends State<GiftRiveAnimation> {
  final riveFileName = 'assets/riv/gift_box.riv';
  Artboard _appearArtBoard;
  RiveAnimationController _appearController;
  LoopAnimation _scaleController;

  @override
  void initState() {
    _loadRiveFile();
    super.initState();
  }

  void _loadRiveFile() async {
    final bytes = await rootBundle.load(riveFileName);
    final file = RiveFile.import(bytes);
    final artBoard = file.mainArtboard;
    //gift_box_scale
    _appearController = SimpleAnimation('gift_box_appear');
    _appearController.isActiveChanged.addListener(() {
      Future.delayed(Duration(milliseconds: 30), () {
        if (!mounted) {
          return;
        }
        setState(() {
          if (_appearController.isActive) {
            // print('Animation started playing');
          } else {
            // print('Animation stopped playing');
            _scaleController = new LoopAnimation('gift_box_scale');
            artBoard.addController(_scaleController);
            _scaleController.start();
          }
        });
      });
    });
    artBoard.addController(_appearController);
    setState(() {
      _appearArtBoard = artBoard;
    });
  }

  @override
  void dispose() {
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _appearArtBoard != null
        ? Rive(
            artboard: _appearArtBoard,
            fit: BoxFit.cover,
          )
        : Container();
  }
}
