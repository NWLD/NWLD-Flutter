import 'dart:async';

typedef PeriodicTimerAction = void Function();
typedef OnPeriodicTimerEnd = void Function(bool max);

class PeriodicTimer {
  Timer countdownTimer;
  int count = 0;
  OnPeriodicTimerEnd onEnd;
  PeriodicTimerAction action;
  int maxCount = 0;

  void start({
    int milliseconds,
    PeriodicTimerAction action,
    int maxCount = 1,
    OnPeriodicTimerEnd onEnd,
    bool firstAction = false,
  }) {
    this.action = action;
    this.onEnd = onEnd;
    this.maxCount = maxCount;
    if (null != countdownTimer) {
      return;
    }
    countdownTimer =
        Timer.periodic(Duration(milliseconds: milliseconds), (timer) {
      if (count >= maxCount) {
        cancel(true);
        return;
      }
      this.action();
      count++;
    });
    if (firstAction) {
      this.action();
      count++;
    }
  }

  void cancel(bool max) {
    if (null != countdownTimer) {
      countdownTimer.cancel();
      countdownTimer = null;
      if (null != onEnd) {
        onEnd(max);
      }
    }
  }
}
