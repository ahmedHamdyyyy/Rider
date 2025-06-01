import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taxi_booking/utils/core/app_routes/navigation_service.dart';
import 'package:taxi_booking/utils/core/app_routes/router_names.dart';
import 'package:taxi_booking/utils/core/widget/shared/custom_search_field.dart';

import '../../../MainScreen.dart';

class TransformedSearchField extends StatelessWidget {
  final String hintText;
  const TransformedSearchField({super.key, this.hintText = "إلي أين ؟"});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainScreen(
                    initialIndex: 1,
                  )),
        );
      },
      child: AbsorbPointer(
          absorbing: true, child: CustomSearchField(hintText: hintText)),
    );
  }
}
