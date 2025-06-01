import 'package:flutter/material.dart';
import 'package:taxi_booking/utils/core/constant/app_icons.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 45,
      decoration: const ShapeDecoration(
        image: DecorationImage(
          image: AssetImage(AppIcons.user),
          fit: BoxFit.fill,
        ),
        shape: OvalBorder(),
      ),
    );
  }
}
