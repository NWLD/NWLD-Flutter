import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kingspro/constants/sizes.dart';

typedef OnCountdownEnd = void Function();

class TimerView extends StatefulWidget {
  final Color color;
  final int initSeconds;
  final OnCountdownEnd onCountdownEnd;

  TimerView({
    Key key,
    @required this.color,
    @required this.initSeconds,
    this.onCountdownEnd,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimerViewState();
  }
}

class TimerViewState extends State<TimerView> {
  String hour = "";
  String min = "";
  String second = "";
  Timer countdownTimer;
  int seconds;

  @override
  void initState() {
    seconds = widget.initSeconds;
    showTimeText(true);
    newTimer();
    super.initState();
  }

  void newTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      seconds--;
      if (0 >= seconds) {
        _cancel();
        if (null != widget.onCountdownEnd) {
          widget.onCountdownEnd();
        }
        return;
      }
      showTimeText(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        buildTimeText(hour),
        buildTimeText(':'),
        buildTimeText(min),
        buildTimeText(':'),
        buildTimeText(second),
      ],
    );
  }

  Widget buildTimeText(String time) {
    return Text(
      time,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: widget.color,
        fontSize: SizeConstant.h7,
        fontFamily: "Barlow-SemiBold",
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void showTimeText(bool init) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    int hours = mins ~/ 60;
    mins = mins % 60;
    hour = hours < 10 ? '0$hours' : '$hours';
    min = mins < 10 ? '0$mins' : '$mins';
    second = secs < 10 ? '0$secs' : '$secs';
    if (init) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
  }

  void _cancel() {
    if (null == countdownTimer) {
      return;
    }
    countdownTimer.cancel();
    countdownTimer = null;
  }
}
