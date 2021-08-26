import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BeautifyAvatar extends StatelessWidget {
  final String avatar;
  final double size;
  final num radius;

  BeautifyAvatar({
    @required this.avatar,
    this.size,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108.w,
      width: 108.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/game/ic_user_avatar.png',
            width: 108.w,
            height: 108.w,
            fit: BoxFit.cover,
          ),
          Container(
            height: 96.w,
            width: 96.w,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(36.w)),
              child: Image.asset(
                'assets/common/avatar_default.png',
                height: 96.w,
                width: 96.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
