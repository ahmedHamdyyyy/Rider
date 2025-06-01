import 'package:flutter/material.dart';
import 'package:taxi_booking/utils/core/utils/responsive_vertical_space.dart';
import 'package:taxi_booking/utils/core/widget/shared/wallet_widget.dart';
import 'package:taxi_booking/screens/settings/wallet_screens/presentation/widgets/add_payment_method_widget.dart';

class WalletAddPaymentMainContent extends StatelessWidget {
  const WalletAddPaymentMainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(children: [
        WalletWidget(
          walletCharged: true,
        ),
        ResponsiveVerticalSpace(24),
        AddPaymentMethodWidget()
      ]),
    );
  }
}
