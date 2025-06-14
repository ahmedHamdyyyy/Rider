import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../main.dart';
import '../../model/ComplaintModel.dart';
import '../../model/DriverRatting.dart';
import '../../network/RestApis.dart';
import '../../utils/Common.dart';
import '../../utils/Extensions/app_common.dart';
import '../../utils/Extensions/app_textfield.dart';
import '../model/RiderModel.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/dataTypeExtensions.dart';
import 'ComplaintListScreen.dart';

class ComplaintScreen extends StatefulWidget {
  final DriverRatting driverRatting;
  final RiderModel? riderModel;
  final ComplaintModel? complaintModel;

  ComplaintScreen(
      {required this.driverRatting, this.complaintModel, this.riderModel});

  @override
  ComplaintScreenState createState() => ComplaintScreenState();
}

class ComplaintScreenState extends State<ComplaintScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController subController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.complaintModel != null) {
      subController.text = widget.complaintModel!.subject.validate();
      descriptionController.text =
          widget.complaintModel!.description.validate();
    }
  }

  Future<void> saveComplainDriver() async {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);
      Map req = {
        "driver_id": widget.riderModel!.driverId,
        "rider_id": sharedPref.getInt(USER_ID),
        "ride_request_id": widget.riderModel!.id,
        "complaint_by": "rider",
        "subject": subController.text.trim(),
        "description": descriptionController.text.trim(),
        "status": PENDING,
      };
      await saveComplain(request: req).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        /*   Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ComplaintListScreen(
                    complaint: widget.complaintModel!.id!))); */
      }).catchError((error) {
        appStore.setLoading(false);

        log(error.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: primaryColor,
              image: DecorationImage(
                image: AssetImage('assets/assets/images/backgroundFrame.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'تقديم شكوى',
            style: boldTextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: appStore.isDarkMode
                          ? scaffoldSecondaryDark
                          : primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(35),
                              child: commonCachedNetworkImage(
                                  widget.riderModel!.driverProfileImage,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(widget.riderModel!.driverName.validate(),
                                    style: boldTextStyle()),
                                SizedBox(height: 8),
                                if (widget.driverRatting.rating != null)
                                  RatingBar.builder(
                                    direction: Axis.horizontal,
                                    glow: false,
                                    allowHalfRating: false,
                                    ignoreGestures: true,
                                    wrapAlignment: WrapAlignment.spaceBetween,
                                    itemCount: 5,
                                    itemSize: 20,
                                    initialRating: double.parse(
                                        widget.driverRatting.rating.toString()),
                                    itemPadding:
                                        EdgeInsets.symmetric(horizontal: 0),
                                    itemBuilder: (context, _) =>
                                        Icon(Icons.star, color: Colors.amber),
                                    onRatingUpdate: (rating) {
                                      //
                                    },
                                  ),
                                if (widget.complaintModel != null)
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 4),
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(
                                              defaultRadius)),
                                      alignment: Alignment.topRight,
                                      child: Text(
                                          widget.complaintModel!.status
                                              .validate(),
                                          style: boldTextStyle(
                                              color: Colors.white)),
                                    ),
                                  )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 26),
                  AppTextField(
                    controller: subController,
                    decoration: inputDecoration(context, label: 'موضوع الشكوى'),
                    textFieldType: TextFieldType.NAME,
                    readOnly: widget.complaintModel != null ? true : false,
                  ),
                  SizedBox(height: 16),
                  AppTextField(
                    controller: descriptionController,
                    readOnly: widget.complaintModel != null ? true : false,
                    decoration:
                        inputDecoration(context, label: 'تفاصيل الشكوى...'),
                    textFieldType: TextFieldType.NAME,
                    minLines: 5,
                    maxLines: 10,
                  ),
                  SizedBox(height: 16),
                  if (widget.complaintModel == null)
                    AppButtonWidget(
                      text: 'إرسال الشكوى',
                      color: primaryColor,
                      width: MediaQuery.of(context).size.width,
                      textStyle: boldTextStyle(color: Colors.white),
                      onTap: () {
                        saveComplainDriver();
                      },
                    ),
                  SizedBox(height: 16),
                  if (widget.complaintModel != null)
                    AppButtonWidget(
                      text: 'عرض جميع الشكاوى',
                      color: primaryColor,
                      width: MediaQuery.of(context).size.width,
                      textStyle: boldTextStyle(color: Colors.white),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ComplaintListScreen(
                                    complaint: widget.complaintModel!.id!)));
                      },
                    ),
                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: loaderWidget(),
            );
          })
        ],
      ),
    );
  }
}
