import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taxi_booking/utils/core/utils/responsive_vertical_space.dart';
import 'package:taxi_booking/utils/core/widget/buttons/app_buttons.dart';
import 'package:taxi_booking/utils/core/widget/shared/wallet_widget.dart';
import 'package:taxi_booking/screens/settings/wallet_screens/presentation/widgets/payment_cards_widget.dart';
import 'package:taxi_booking/utils/core/constant/styles/app_text_style.dart';
import 'package:taxi_booking/network/RestApis.dart';
import 'package:taxi_booking/utils/Extensions/app_common.dart';
import 'package:taxi_booking/screens/PaymentScreen.dart';
import 'package:taxi_booking/utils/core/constant/app_colors.dart';

class WalletAddChargeMainContent extends StatefulWidget {
  const WalletAddChargeMainContent({super.key});

  @override
  State<WalletAddChargeMainContent> createState() =>
      _WalletAddChargeMainContentState();
}

class _WalletAddChargeMainContentState
    extends State<WalletAddChargeMainContent> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال المبلغ';
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'الرجاء إدخال مبلغ صحيح';
    }
    return null;
  }

  Future<void> _chargeWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);

      // Navigate to payment screen
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(amount: amount),
        ),
      );

      if (result == true) {
        toast('تم شحن المحفظة بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      toast('حدث خطأ أثناء شحن المحفظة');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletWidget(
              walletCharged: true,
              addCharged: true,
            ),
            const ResponsiveVerticalSpace(24),
            Text(
              'المبلغ',
              style: AppTextStyles.sSemiBold16(),
            ),
            const ResponsiveVerticalSpace(16),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  color: AppColors.textColor,
                  fontSize: 16,
                  fontFamily: 'Tajawal',
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'أدخل المبلغ',
                  hintStyle: TextStyle(
                    color: AppColors.gray,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                validator: _validateAmount,
              ),
            ),
            const ResponsiveVerticalSpace(24),
            const PaymentCardsWidget(),
            const ResponsiveVerticalSpace(24),
            AppButtons.primaryButton(
              title: _isLoading ? 'جاري الشحن...' : 'شحن المحفظة',
              onPressed: _isLoading ? null : _chargeWallet,
            ),
          ],
        ),
      ),
    );
  }
}
