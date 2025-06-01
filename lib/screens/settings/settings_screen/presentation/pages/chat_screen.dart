import 'package:flutter/material.dart';
import 'package:taxi_booking/utils/core/constant/app_colors.dart';
import 'package:taxi_booking/screens/settings/settings_screen/presentation/widgets/chat/chat_screen_body.dart';
import 'package:taxi_booking/screens/settings/settings_screen/presentation/widgets/chat/send_message_bottom_bar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: ChatScreenBody(),
      bottomNavigationBar: SendMessageBottomBar(),
    );
  }
}
