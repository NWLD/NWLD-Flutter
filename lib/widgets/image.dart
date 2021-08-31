import 'package:flutter/material.dart';

class ClipImage extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final String url;
  final Color boxColor;
  final BoxFit fit;

  ClipImage({
    Key key,
    this.url = "",
    this.width = 20,
    this.height = 20,
    this.radius = 9,
    this.boxColor = const Color(0x40FFFFFF),
    this.fit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: AlignmentDirectional.center,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.asset(
          url,
          fit: fit ?? BoxFit.fill,
          width: width,
          height: height,
        ),
      ),
    );
  }
}
