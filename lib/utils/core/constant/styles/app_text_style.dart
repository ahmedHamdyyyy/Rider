import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constant/app_colors.dart';

extension AppTextStyles on TextStyle {
  static TextStyle sSemiBold16({Color color = AppColors.textColor}) =>
      TextStyle(color: color, fontSize: 16.spMin, fontWeight: FontWeight.w700);

  static TextStyle sSemiBold14({Color color = AppColors.gray}) =>
      TextStyle(color: color, fontSize: 14.spMin, fontWeight: FontWeight.w700);

  static TextStyle sMedium16({Color color = AppColors.textColor}) =>
      TextStyle(color: color, fontSize: 16.spMin, fontWeight: FontWeight.w500);

  static TextStyle sMedium14({Color color = AppColors.primary}) =>
      TextStyle(color: color, fontSize: 14.spMin, fontWeight: FontWeight.w500);

  static TextStyle sRegular14({Color color = AppColors.textColor}) =>
      TextStyle(color: color, fontSize: 14.spMin, fontWeight: FontWeight.w400);
}
