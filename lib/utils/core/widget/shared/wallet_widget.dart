import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_booking/screens/settings/wallet_screens/presentation/pages/wallet_add_paymentMethod_screen.dart';
import 'package:taxi_booking/screens/settings/wallet_screens/presentation/pages/wallet_charged_screen.dart';
import 'package:taxi_booking/utils/core/app_routes/navigation_service.dart';
import 'package:taxi_booking/utils/core/app_routes/router_names.dart';
import 'package:taxi_booking/utils/core/constant/app_colors.dart';
import 'package:taxi_booking/utils/core/constant/app_image.dart';
import 'package:taxi_booking/utils/core/constant/styles/app_text_style.dart';
import 'package:taxi_booking/utils/core/widget/buttons/app_buttons.dart';

class WalletWidget extends StatelessWidget {
  final bool walletCharged;
  final bool addCharged;
  const WalletWidget(
      {super.key, this.walletCharged = false, this.addCharged = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 156.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        // color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: AssetImage("assets/assets/images/walletFrame.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (walletCharged || addCharged) ? 'رصيد المحفظه' : 'المحفظه',
            style: AppTextStyles.sMedium16(color: AppColors.white),
          ),
          Text(
            (walletCharged || addCharged) ? '1200 ريال سعودي' : 'لا يوجد محفظه',
            style: AppTextStyles.sMedium16(color: AppColors.white),
          ),
          const Spacer(),
          AppButtons.primaryButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const WalletAddPaymentMethodScreen()));

                if (walletCharged) {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WalletAddChargeScreen()));
                }
              },
              title: walletCharged
                  ? 'شحن المحفظه'
                  : addCharged
                      ? 'برجاء ادخال القيمه'
                      : "إنشاء محفظه",
              bgColor: AppColors.white.withOpacity(.3)),
        ],
      ),
    );
  }
}
