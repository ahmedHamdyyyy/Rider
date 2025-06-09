import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/rendering.dart';

import '../main.dart';
import '../model/CurrentRequestModel.dart';
import '../network/RestApis.dart';
import '../utils/Colors.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/images.dart';
import '../screens/NewEstimateRideListWidget.dart';
import '../screens/MainScreen.dart';
import '../screens/ChatScreen.dart';
import '../model/LoginResponse.dart';
import '../service/ChatMessagesService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverSelectionScreen extends StatefulWidget {
  final int rideRequestId;
  final String sourceTitle;
  final String destinationTitle;
  final LatLng sourceLatLog;
  final LatLng destinationLatLog;
  final String? dt;

  const DriverSelectionScreen({
    Key? key,
    required this.rideRequestId,
    required this.sourceTitle,
    required this.destinationTitle,
    required this.sourceLatLog,
    required this.destinationLatLog,
    this.dt,
  }) : super(key: key);

  @override
  _DriverSelectionScreenState createState() => _DriverSelectionScreenState();
}

class _DriverSelectionScreenState extends State<DriverSelectionScreen>
    with TickerProviderStateMixin {
  List<Driver> availableDrivers = [];
  Driver? selectedDriver;
  bool isLoading = true;
  Timer? refreshTimer;
  ChatMessageService chatMessageService = ChatMessageService();
  Map<int, double> driverRatings = {}; // Cache for driver ratings

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadAvailableDrivers();
    _startPeriodicRefresh();

    // Add haptic feedback when the screen loads
    HapticFeedback.mediumImpact();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  void _startPeriodicRefresh() {
    refreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (mounted) {
        _loadAvailableDrivers();
      }
    });
  }

  Future<void> _loadAvailableDrivers() async {
    try {
      // First check if there's an ongoing ride with an accepted driver
      final currentRequest = await getCurrentRideRequest();
      final rideRequest =
          currentRequest.rideRequest ?? currentRequest.onRideRequest;

      if (rideRequest != null && rideRequest.status == ACCEPTED) {
        // Get driver details for accepted ride
        if (rideRequest.driverId != null) {
          final driverData = await getUserDetail(userId: rideRequest.driverId);
          if (driverData.data != null) {
            setState(() {
              availableDrivers = [
                Driver(
                  id: driverData.data!.id,
                  firstName: driverData.data!.firstName,
                  lastName: driverData.data!.lastName,
                  profileImage: driverData.data!.profileImage,
                  contactNumber: driverData.data!.contactNumber,
                  email: driverData.data!.email,
                  latitude: driverData.data!.latitude,
                  longitude: driverData.data!.longitude,
                  isOnline: 1,
                  isAvailable: 1,
                )
              ];
              isLoading = false;
            });

            // Load driver ratings and details asynchronously
            _loadDriverRatings();
            _loadDriverDetails();
          }
        }
      } else {
        // Load nearby available drivers
        try {
          final nearbyDrivers =
              await getNearByDriverList(latLng: widget.sourceLatLog);
          if (nearbyDrivers.data != null && nearbyDrivers.data!.isNotEmpty) {
            setState(() {
              availableDrivers = nearbyDrivers.data!.map((nearbyDriver) {
                // Store the rating directly from the API response
                if (nearbyDriver.id != null && nearbyDriver.rating != null) {
                  driverRatings[nearbyDriver.id!] =
                      nearbyDriver.rating!.toDouble();
                }

                return Driver(
                  id: nearbyDriver.id,
                  firstName: nearbyDriver.firstName,
                  lastName: nearbyDriver.lastName,
                  displayName: nearbyDriver.displayName,
                  latitude: nearbyDriver.latitude,
                  longitude: nearbyDriver.longitude,
                  isOnline: nearbyDriver.isOnline?.toInt(),
                  isAvailable: nearbyDriver.isAvailable?.toInt(),
                );
              }).toList();
              isLoading = false;
            });
            // Load driver details for nearby drivers
            _loadDriverDetails();
          } else {
            setState(() {
              availableDrivers = [];
              isLoading = false;
            });
          }
        } catch (e) {
          print('Error loading nearby drivers: $e');
          setState(() {
            availableDrivers = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading drivers: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Calculate distance between two points
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Calculate estimated arrival time
  String _calculateEstimatedTime(double distanceKm) {
    // Assuming average speed of 30 km/h in city traffic
    double timeInHours = distanceKm / 30;
    int timeInMinutes = (timeInHours * 60).round();

    if (timeInMinutes < 1) {
      return "أقل من دقيقة";
    } else if (timeInMinutes == 1) {
      return "دقيقة واحدة";
    } else if (timeInMinutes == 2) {
      return "دقيقتان";
    } else if (timeInMinutes <= 10) {
      return "$timeInMinutes دقائق";
    } else {
      return "$timeInMinutes دقيقة";
    }
  }

  // Get driver rating
  double _getDriverRating(Driver driver) {
    // Return cached rating if available, otherwise return 0 to indicate no rating
    return driverRatings[driver.id] ?? 0.0;
  }

  // Get driver's real rating from API
  Future<double> _getDriverRealRating(Driver driver) async {
    try {
      final driverDetail = await getDriverDetail(userId: driver.id);
      if (driverDetail.data?.rating != null) {
        double rating = driverDetail.data!.rating!.toDouble();
        // Cache the rating
        driverRatings[driver.id!] = rating;
        return rating;
      } else {
        return 0; // Default if no rating available
      }
    } catch (e) {
      print('Error getting driver rating: $e');
      return 4.5; // Default if error occurs
    }
  }

  // Load driver ratings asynchronously
  Future<void> _loadDriverRatings() async {
    for (Driver driver in availableDrivers) {
      if (driver.id != null && !driverRatings.containsKey(driver.id)) {
        final rating = await _getDriverRealRating(driver);
        if (mounted) {
          setState(() {
            driverRatings[driver.id!] = rating;
          });
        }
      }
    }
  }

  // Load driver details including car information
  Future<void> _loadDriverDetails() async {
    for (int i = 0; i < availableDrivers.length; i++) {
      Driver driver = availableDrivers[i];
      if (driver.id != null && driver.userDetail == null) {
        try {
          final driverDetailResponse = await getDriverDetail(userId: driver.id);
          if (driverDetailResponse.data?.userDetail != null && mounted) {
            setState(() {
              availableDrivers[i].userDetail = UserDetail(
                carModel: driverDetailResponse.data!.userDetail!.carModel,
                carPlateNumber:
                    driverDetailResponse.data!.userDetail!.carPlateNumber,
                carColor: driverDetailResponse.data!.userDetail!.carColor,
                carProductionYear:
                    driverDetailResponse.data!.userDetail!.carProductionYear,
              );
            });
          }
        } catch (e) {
          print('Error loading driver details for driver ${driver.id}: $e');
        }
      }
    }
  }

  // Get driver distance
  String _getDriverDistance(Driver driver) {
    if (driver.latitude != null && driver.longitude != null) {
      try {
        double driverLat = double.parse(driver.latitude!);
        double driverLon = double.parse(driver.longitude!);
        double distance = _calculateDistance(
          widget.sourceLatLog.latitude,
          widget.sourceLatLog.longitude,
          driverLat,
          driverLon,
        );

        if (distance < 1) {
          return "${(distance * 1000).round()} م";
        } else {
          return "${distance.toStringAsFixed(1)} كم";
        }
      } catch (e) {
        return "2.5 كم"; // Default fallback
      }
    }
    return "2.5 كم"; // Default fallback
  }

  // Get estimated arrival time
  String _getEstimatedArrivalTime(Driver driver) {
    if (driver.latitude != null && driver.longitude != null) {
      try {
        double driverLat = double.parse(driver.latitude!);
        double driverLon = double.parse(driver.longitude!);
        double distance = _calculateDistance(
          widget.sourceLatLog.latitude,
          widget.sourceLatLog.longitude,
          driverLat,
          driverLon,
        );

        return _calculateEstimatedTime(distance);
      } catch (e) {
        return "5 دقائق"; // Default fallback
      }
    }
    return "5 دقائق"; // Default fallback
  }

  Future<void> _acceptDriver(Driver driver) async {
    try {
      appStore.setLoading(true);

      // Accept the driver
      Map req = {
        "id": widget.rideRequestId.toString(),
        "driver_id": driver.id.toString(),
        "status": ACCEPTED,
      };

      await rideRequestUpdate(request: req, rideId: widget.rideRequestId);

      appStore.setLoading(false);

      // Show success message
      toast("تم قبول السائق بنجاح!");

      // Navigate to ride details
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => NewEstimateRideListWidget(
            dt: widget.dt,
            sourceLatLog: widget.sourceLatLog,
            destinationLatLog: widget.destinationLatLog,
            sourceTitle: widget.sourceTitle,
            destinationTitle: widget.destinationTitle,
            isCurrentRequest: true,
            id: widget.rideRequestId,
          ),
        ),
      );
    } catch (error) {
      appStore.setLoading(false);
      toast("حدث خطأ أثناء قبول السائق");
    }
  }

  Future<void> _rejectDriver(Driver driver) async {
    try {
      appStore.setLoading(true);

      // Reject the driver and cancel the ride
      Map req = {
        "id": widget.rideRequestId.toString(),
        "status": CANCELED,
        "cancel_by": RIDER,
        "reason": "تم رفض السائق من قبل المستخدم",
      };

      await rideRequestUpdate(request: req, rideId: widget.rideRequestId);

      appStore.setLoading(false);
      toast("تم رفض السائق وإلغاء الرحلة");

      // Navigate back to dashboard
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(initialIndex: 1),
        ),
        (route) => false,
      );
    } catch (error) {
      appStore.setLoading(false);
      toast("حدث خطأ أثناء رفض السائق");
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "اختيار السائق",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: 1),
                ),
                (route) => false,
              );
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  // Enhanced Header section
                  Container(
                    padding: EdgeInsets.all(24),
                    margin: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.8),
                          primaryColor.withOpacity(0.9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "تم العثور على سائق!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "يرجى اختيار السائق المناسب لرحلتك",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Drivers list
                  Expanded(
                    child: isLoading
                        ? _buildLoadingWidget()
                        : availableDrivers.isEmpty
                            ? _buildEmptyWidget()
                            : _buildDriversList(),
                  ),
                ],
              ),
            ),
          ),
          Observer(builder: (context) {
            return Visibility(
              visible: appStore.isLoading,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                        SizedBox(height: 16),
                        Text(
                          "جاري المعالجة...",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            bookingAnim,
            height: 120,
            width: 120,
          ),
          SizedBox(height: 20),
          Text(
            "جاري البحث عن السائقين المتاحين...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 20),
          Text(
            "لا يوجد سائقين متاحين حالياً",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 30),
          AppButtonWidget(
            text: "العودة للرئيسية",
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: 1),
                ),
                (route) => false,
              );
            },
            color: primaryColor,
            textStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: availableDrivers.length,
      itemBuilder: (context, index) {
        final driver = availableDrivers[index];
        final driverRating = _getDriverRating(driver);
        final driverDistance = _getDriverDistance(driver);
        final estimatedTime = _getEstimatedArrivalTime(driver);

        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: selectedDriver?.id == driver.id
                  ? primaryColor
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  selectedDriver = driver;
                });
                HapticFeedback.lightImpact();
              },
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Enhanced Driver avatar with online indicator
                        GestureDetector(
                          onTap: () => _showDriverProfile(driver),
                          child: Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.7)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.all(3),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: driver.profileImage != null &&
                                            driver.profileImage!.isNotEmpty
                                        ? Image.network(
                                            driver.profileImage!,
                                            fit: BoxFit.cover,
                                            height: 74,
                                            width: 74,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 74,
                                                width: 74,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.grey[400],
                                                  size: 35,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            height: 74,
                                            width: 74,
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: Colors.grey[400],
                                              size: 35,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              // Enhanced online indicator
                              Positioned(
                                bottom: 5,
                                right: 5,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tap indicator
                            ],
                          ),
                        ),
                        SizedBox(width: 20),

                        // Enhanced Driver info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                "${driver.firstName ?? ''} ${driver.lastName ?? ''}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontFamily: 'Tajawal',
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: driverRating > 0
                                          ? Colors.amber[50]
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: driverRating > 0
                                              ? Colors.amber[200]!
                                              : Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star,
                                            color: driverRating > 0
                                                ? Colors.amber
                                                : Colors.grey[400],
                                            size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          driverRating > 0
                                              ? driverRating.toStringAsFixed(1)
                                              : "لا يوجد",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: driverRating > 0
                                                ? Colors.amber[800]
                                                : Colors.grey[600],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.blue[200]!),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.location_on,
                                            color: Colors.blue[600], size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          driverDistance,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Estimated arrival time
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[50]!,
                                      Colors.green[100]!
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.green[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /*    Icon(Icons.access_time,
                                        color: Colors.green[700], size: 18),
                                    SizedBox(width: 6), */
                                    Text(
                                      "يصل خلال $estimatedTime",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Car details section
                              SizedBox(height: 8),
                              if (driver.userDetail?.carModel != null ||
                                  driver.userDetail?.carPlateNumber != null)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (driver.userDetail?.carModel !=
                                        null) ...[
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.purple[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.purple[200]!),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.directions_car,
                                                color: Colors.purple[600],
                                                size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              "موديل السيارة: ${driver.userDetail!.carModel!}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.purple[800],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                    ],
                                    if (driver.userDetail?.carPlateNumber !=
                                        null)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.orange[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: Colors.orange[200]!),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.confirmation_number,
                                                color: Colors.orange[600],
                                                size: 16),
                                            SizedBox(width: 4),
                                            Text(
                                              "رقم اللوحة: ${driver.userDetail!.carPlateNumber!}",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.orange[800],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        /*       // Enhanced Chat and Call buttons
                        Column(
                          children: [
                            // Chat button
                            InkWell(
                              onTap: () => _openChatWithDriver(driver),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor,
                                      primaryColor.withOpacity(0.8)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                            /*      SizedBox(height: 12),
                            // Call button
                            InkWell(
                              onTap: () => _callDriver(driver),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.green[600]!,
                                      Colors.green[700]!
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                         */
                          ],
                        ),
                   */
                      ],
                    ),

                    SizedBox(height: 24),

                    // Enhanced Action buttons
                    Row(
                      children: [
                        // Reject button
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => _rejectDriver(driver),
                              icon: Icon(Icons.close, size: 20),
                              label: Text(
                                "رفض",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[50],
                                foregroundColor: Colors.red[700],
                                elevation: 0,
                                side: BorderSide(
                                    color: Colors.red[200]!, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        // Accept button
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () => _acceptDriver(driver),
                              icon: Icon(Icons.check, size: 20),
                              label: Text(
                                "قبول",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: primaryColor.withOpacity(0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Opens chat screen with the selected driver
  Future<void> _openChatWithDriver(Driver driver) async {
    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text("جاري فتح المحادثة..."),
            ],
          ),
          duration: Duration(seconds: 1),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Create UserModel for the driver to use in ChatScreen
      UserModel driverUserModel = UserModel(
        id: driver.id,
        firstName: driver.firstName,
        lastName: driver.lastName,
        email: driver.email,
        contactNumber: driver.contactNumber,
        profileImage: driver.profileImage,
        uid: driver.uid ?? driver.id.toString(),
        playerId: driver.playerId,
      );

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            userData: driverUserModel,
            ride_id: widget.rideRequestId,
          ),
        ),
      );
    } catch (error) {
      toast("حدث خطأ أثناء فتح المحادثة");
      print('Error opening chat: $error');
    }
  }

  /// Makes a phone call to the selected driver
  Future<void> _callDriver(Driver driver) async {
    try {
      // Add haptic feedback
      HapticFeedback.lightImpact();

      if (driver.contactNumber != null && driver.contactNumber!.isNotEmpty) {
        // Show confirmation dialog
        bool? shouldCall = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                "إجراء مكالمة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("هل تريد الاتصال بالسائق؟"),
                  SizedBox(height: 8),
                  Text(
                    "${driver.firstName ?? ''} ${driver.lastName ?? ''}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    driver.contactNumber!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    "إلغاء",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("اتصال"),
                ),
              ],
            );
          },
        );

        if (shouldCall == true) {
          final Uri phoneUri = Uri.parse('tel:${driver.contactNumber}');
          if (await canLaunchUrl(phoneUri)) {
            await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
          } else {
            toast("لا يمكن إجراء المكالمة");
          }
        }
      } else {
        toast("رقم الهاتف غير متوفر");
      }
    } catch (error) {
      toast("حدث خطأ أثناء إجراء المكالمة");
      print('Error making call: $error');
    }
  }

  /// Shows driver profile dialog when tapping on driver image
  void _showDriverProfile(Driver driver) {
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [Colors.white, Colors.grey[50]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "بروفايل السائق",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close, color: Colors.grey[600]),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                // Driver Image
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: driver.profileImage != null &&
                              driver.profileImage!.isNotEmpty
                          ? Image.network(
                              driver.profileImage!,
                              fit: BoxFit.cover,
                              height: 92,
                              width: 92,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 92,
                                  width: 92,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[400],
                                    size: 45,
                                  ),
                                );
                              },
                            )
                          : Container(
                              height: 92,
                              width: 92,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: Colors.grey[400],
                                size: 45,
                              ),
                            ),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                // Driver Name
                Text(
                  "${driver.firstName ?? ''} ${driver.lastName ?? ''}",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                SizedBox(height: 8),

                // Rating
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getDriverRating(driver) > 0
                        ? Colors.amber[50]
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _getDriverRating(driver) > 0
                            ? Colors.amber[200]!
                            : Colors.grey[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star,
                          color: _getDriverRating(driver) > 0
                              ? Colors.amber
                              : Colors.grey[400],
                          size: 18),
                      SizedBox(width: 6),
                      Text(
                        _getDriverRating(driver) > 0
                            ? _getDriverRating(driver).toStringAsFixed(1)
                            : "لا يوجد",
                        style: TextStyle(
                          fontSize: 16,
                          color: _getDriverRating(driver) > 0
                              ? Colors.amber[800]
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "تقييم",
                        style: TextStyle(
                          fontSize: 14,
                          color: _getDriverRating(driver) > 0
                              ? Colors.amber[700]
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Driver Details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildProfileRow(
                        icon: Icons.location_on,
                        title: "المسافة",
                        value: _getDriverDistance(driver),
                        color: Colors.blue[600]!,
                      ),
                      SizedBox(height: 12),
                      _buildProfileRow(
                        icon: Icons.access_time,
                        title: "وقت الوصول المتوقع",
                        value: _getEstimatedArrivalTime(driver),
                        color: Colors.green[600]!,
                      ),
                      if (driver.contactNumber != null &&
                          driver.contactNumber!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        _buildProfileRow(
                          icon: Icons.phone,
                          title: "رقم الهاتف",
                          value: driver.contactNumber!,
                          color: Colors.orange[600]!,
                        ),
                      ],
                      if (driver.email != null && driver.email!.isNotEmpty) ...[
                        SizedBox(height: 12),
                        _buildProfileRow(
                          icon: Icons.email,
                          title: "البريد الإلكتروني",
                          value: driver.email!,
                          color: Colors.purple[600]!,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _callDriver(driver);
                        },
                        icon: Icon(Icons.phone, size: 18),
                        label: Text("اتصال"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _openChatWithDriver(driver);
                        },
                        icon: Icon(Icons.chat, size: 18),
                        label: Text("محادثة"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
