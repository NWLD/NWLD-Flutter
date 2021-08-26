import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/sizes.dart';

class SlidePageView extends StatefulWidget {
  final List<Widget> children;
  final SlidePageController controller;

  SlidePageView({
    Key key,
    @required this.children,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SlidePageViewState();
  }
}

class _SlidePageViewState extends State<SlidePageView> with TickerProviderStateMixin {
  double scrollLeft = 0;
  AnimationController _animationController;
  int index = 0;
  bool forward = true;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 150,
      ),
    );
    _animationController.addListener(() {
      setState(() {
        if (forward) {
          scrollLeft = (index * 750.w) + 750.w * _animationController.value;
        } else {
          scrollLeft = (index * 750.w) - 750.w * _animationController.value;
        }
      });
    });
    _animationController.addStatusListener((status) {
      if (AnimationStatus.completed == status) {
        setState(() {
          if (forward) {
            index++;
          } else {
            index--;
          }
          if (null != widget.controller) {
            widget.controller.onPageChanged(index);
          }
        });
      }
    });
    widget.controller.nextPage = nextPage;
    widget.controller.prePage = prePage;
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              // 触摸收起键盘
              hideInput();
            },
            child: Stack(
              children: buildChildren(constraints.maxHeight),
            ),
          );
        },
      ),
    );
  }

  List<Widget> buildChildren(double maxHeight) {
    List<Widget> list = [];
    int size = widget.children.length;
    for (int index = 0; index < size; index++) {
      Widget child = Positioned(
        left: index * 750.w - scrollLeft,
        width: 750.w,
        child: Container(
          height: maxHeight,
          child: widget.children[index],
        ),
      );
      list.add(child);
    }
    return list;
  }

  void hideInput() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void nextPage() {
    if (_animationController.isAnimating) {
      return;
    }
    if (widget.children.length - 1 == index) {
      return;
    }
    setState(() {
      forward = true;
      _animationController.forward(from: 0);
    });
  }

  void prePage() {
    if (_animationController.isAnimating) {
      return;
    }
    if (0 == index) {
      return;
    }
    setState(() {
      forward = false;
      _animationController.forward(from: 0);
    });
  }
}

class SlidePageController {
  Function nextPage;
  Function prePage;
  Function onPageChanged;
}
