import 'package:flutter/material.dart';
import 'package:taxi_booking/screens/settings/help/presentation/pages/amount_paid_contact_screen.dart';
import 'package:taxi_booking/screens/settings/settings_screen/presentation/pages/chat_screen.dart';
import 'package:taxi_booking/utils/core/app_routes/navigation_service.dart';
import 'package:taxi_booking/utils/core/app_routes/router_names.dart';
import 'package:taxi_booking/utils/core/constant/styles/app_text_style.dart';
import 'package:taxi_booking/utils/core/utils/responsive_vertical_space.dart';
import 'package:taxi_booking/screens/settings/help/domain/entity/help_page_entity.dart';
import 'package:taxi_booking/screens/settings/settings_screen/presentation/widgets/list_title_widget.dart';

class RideProblemsWidget extends StatelessWidget {
  const RideProblemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        "رحله من التسعين الي الجامعه",
        style: AppTextStyles.sSemiBold16(),
      ),
      const ResponsiveVerticalSpace(16),
      Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Color(0x15000000),
                blurRadius: 4,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              CustomListTitleWidget(
                onTap: () {
                  NavigationService.pushNamed(
                      RouterNames.helperContactMessageScreen,
                      arguments: HelpPageEntity(
                          onTap: () {
                            NavigationService.pushNamed(
                                RouterNames.amountPaidContactScreen);
                          },
                          title: 'لم يتم اضافه الباقي في المحفظه',
                          content: '''نحن نعتذر بصدق عن الإزعاج.
في بعض الأحيان يتعين على الكباتن التعامل مع عوامل خارجة عن سيطرتهم مثل حركة المرور أو أعمال الطرق أو التحويلات.

إذا شعرت أن الكابتن كان غير مسؤول وتسبب في زيادة رسوم رحلتك، فيرجى الإبلاغ عن المشكلة أدناه.

يرجى التواصل معنا خلال 7 أيام من وقوع الحادث، وإلا فلن نتمكن من مراجعة الأسعار'''));
                },
                title: "لم يتم اضافه الباقي في المحفظه",
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
                height: 1,
              ),
              CustomListTitleWidget(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const AmountPaidContactScreen()));
                  ;
                },
                title: "اضعت شي",
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
                height: 1,
              ),
              CustomListTitleWidget(
                title: "تواصل معانا",
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatScreen()));
                },
              ),
            ],
          ))
    ]);
  }
}
