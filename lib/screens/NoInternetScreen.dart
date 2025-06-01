import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../main.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';

class NoInternetScreen extends StatefulWidget {
  @override
  _NoInternetScreenState createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: netScreenKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              image: DecorationImage(
                image: AssetImage(IMAGE_BACKGROUND),
                fit: BoxFit.cover,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'لا يوجد اتصال بالإنترنت',
            style: boldTextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(networkErrorView,
              width: 200, height: 200, fit: BoxFit.contain),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(" اعتذر  ولكن يبدو أن لا يوجد اتصال بالإنترنت",
                textAlign: TextAlign.start,
                style: secondaryTextStyle(size: 20)),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: AppButtonWidget(
            width: MediaQuery.of(context).size.width,
            text: "حاول مرة أخرى",
            textColor: primaryColor,
            color: Colors.white,
            shapeBorder: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(defaultRadius),
                side: BorderSide(color: primaryColor)),
            onTap: () async {
              List<ConnectivityResult> b =
                  await Connectivity().checkConnectivity();
              if (!b.contains(ConnectivityResult.none)) {
                if (Navigator.canPop(
                    navigatorKey.currentState!.overlay!.context)) {
                  Navigator.pop(navigatorKey.currentState!.overlay!.context);
                }
              } else {
                toast('لا يوجد اتصال بالإنترنت');
              }
            }),
      ),
    );
  }
}
