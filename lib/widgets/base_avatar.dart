import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BaseAvatar extends StatelessWidget {
  final String avatar;
  final double size;
  final BoxBorder border;
  final num radius;
  final String placeholder;

  BaseAvatar({
    @required this.avatar,
    @required this.size,
    this.border,
    this.radius,
    this.placeholder = 'assets/abc/avatar_default.png',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: border ?? Border.all(color: Colors.white, width: 2.w),
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 100.w)),
      ),
      child: ClipOval(
        child: avatar != null && avatar.contains('http')
            ? FadeInImage.assetNetwork(
                placeholder: placeholder,
                image: avatar ?? '',
                height: size,
                width: size,
                fit: BoxFit.fitWidth,
              )
            : Image.asset(
                avatar ?? placeholder,
                height: size,
                width: size,
                fit: BoxFit.fitWidth,
              ),
      ),
    );
  }
}
