import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kingspro/models/settings_model.dart';
import 'package:provider/provider.dart';

import 'car_anim.dart';

class CarAnimations extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CarAnimationsState();
  }
}

class _CarAnimationsState extends State<CarAnimations> {
  List<Car> cars = [];
  CarPathController carPathController = CarPathController();

  @override
  void initState() {
    carPathController.onPathEnd = onCarPathEnd;
    carPathController.onRemoved = onCarPathRemoved;
    //TODO 设置模型
    for (int index = 0; index < 10; index++) {
      cars.add(null);
    }
    super.initState();
  }

  void onCarPathEnd(Car car, double progress) {
    Future.delayed(Duration(milliseconds: 30), () {

    });
  }

  void onCarPathRemoved(Car car, double progress) {
    //车被删除时，根据跑道的百分比加金币
    Future.delayed(Duration(milliseconds: 30), () {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(builder: (context, gameModel, child) {
      setCars(gameModel);
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...buildItems(),
            ],
          );
        },
      );
    });
  }

  setCars(var gameModel) {
    List roomItems = gameModel.roomItems;
    List<Car> carList = [];
    int len = roomItems.length;
    for (int index = 0; index < len; index++) {
      var roomItem = roomItems[index];
      if (null == roomItem) {
        carList.add(null);
        continue;
      }
      if (1 != roomItem.type) {
        carList.add(null);
        continue;
      }
      carList.add(createCar(index, roomItem.level, gameModel));
    }
    cars = carList;
  }

  Car createCar(int index, int level, var gameModel) {
    if (cars.length <= index) {
      return newCar(index, level, gameModel);
    }
    Car car = cars[index];
    if (null == car || level != car.level) {
      return newCar(index, level, gameModel);
    }
    return cars[index];
  }

  Car newCar(int index, int level, var gameModel) {
    String icon = getCarPath(level);
    var dogItem = gameModel.findDogByLevel(level);

    double dogCountFactor = 3 * sqrt(gameModel.roomDogCount); // 车越多，车速越慢，保证无论车多车少，一个比较好的节奏。范围 [3, 11.6)
    double levelFactor = sqrt(sqrt(level)); // 级别越高，车速越快 [1, 3)
    int factor = (dogCountFactor - levelFactor).toInt(); // 综合因素
    int seconds = randomInt(5 + factor, 10 + factor);

    return Car(
      pos: index,
      //跑道动画时间
      pathSeconds: seconds,
      perCoin: dogItem.coin_per_second ?? '1',
      icon: icon,
      level: level,
    );
  }

  static num random(num min, num max) {
    return (new Random()).nextDouble() * (max - min) + min;
  }

  /**
   * 随机一个整数，区间为 [min, max)
   */
  static int randomInt(int min, int max) {
    return random(min, max).toInt();
  }

  String getCarPath(int index) {
    return 'assets/runcars/run_car$index.png';
  }

  List<Widget> buildItems() {
    List<Widget> list = [];
    int len = cars.length;
    for (int index = 0; index < len; index++) {
      Car car = cars[index];
      Widget itemWidget = null == car
          ? Container()
          : CarAnimation(
              car: cars[index],
              controller: carPathController,
            );
      list.add(itemWidget);
    }
    return list;
  }
}
