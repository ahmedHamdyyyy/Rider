import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:taxi_booking/utils/Extensions/dataTypeExtensions.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../main.dart';
import '../../network/RestApis.dart';
import '../model/UserDetailModel.dart';
import '../model/WalletListModel.dart';
import '../screens/WithDrawScreen.dart';
import '../utils/Colors.dart';
import '../utils/Common.dart';
import '../utils/Constants.dart';
import '../utils/Extensions/AppButtonWidget.dart';
import '../utils/Extensions/app_common.dart';
import '../utils/Extensions/app_textfield.dart';
import 'BankInfoScreen.dart';
import 'PaymentScreen.dart';
import '../components/ModernAppBar.dart';

class WalletScreen extends StatefulWidget {
  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController addMoneyController = TextEditingController();
  ScrollController scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int currentPage = 1;
  int totalPage = 1;
  int currentIndex = -1;
  List<WalletModel> walletData = [];
  num totalAmount = 0;
  UserBankAccount? userBankAccount;
  bool showShadow = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    init();
    scrollController.addListener(() {
      setState(() {
        showShadow = scrollController.offset > 0;
      });

      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (currentPage < totalPage) {
          appStore.setLoading(true);
          currentPage++;
          setState(() {});
          init();
        }
      }
    });
    afterBuildCreated(() => appStore.setLoading(true));
  }

  @override
  void dispose() {
    _animationController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void init() async {
    getBankDetail();
    getWalletListApi();
  }

  getWalletListApi() async {
    await getWalletList(page: currentPage).then((value) {
      appStore.setLoading(false);

      currentPage = value.pagination!.currentPage!;
      totalPage = value.pagination!.totalPages!;
      if (value.walletBalance != null)
        totalAmount = value.walletBalance!.totalAmount!;
      if (currentPage == 1) {
        walletData.clear();
      }
      walletData.addAll(value.data ?? []);
      setState(() {});
    }).catchError((error) {
      appStore.setLoading(false);
      log(error.toString());
    });
  }

  getBankDetail() async {
    await getUserDetail(userId: sharedPref.getInt(USER_ID)).then((value) {
      userBankAccount = value.data!.userBankAccount;
      setState(() {});
    }).then((value) {
      log(value);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: ModernAppBar(
        title: "المحفظة",
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: RefreshIndicator(
                onRefresh: () async {
                  init();
                },
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWalletCard(),
                      _buildQuickActions(),
                      _buildStatisticsCards(),
                      _buildTransactionsList(),
                    ],
                  ),
                ),
              ),
            ),

            // Loader
            if (appStore.isLoading)
              Container(
                color: Colors.black12,
                child: Center(
                  child: loaderWidget(),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E3C72),
                  Color(0xFF2A5298),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1E3C72).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
          ),
          Positioned(
            right: -50,
            top: -50,
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              height: 140,
              width: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        MaterialCommunityIcons.wallet_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 12),
                      Text(
                        "رصيد المحفظة",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ر.س",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: printAmountWidget(
                          amount:
                              totalAmount.toStringAsFixed(digitAfterDecimal),
                          size: 40,
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          MaterialCommunityIcons.shield_check_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "محفظة آمنة 100%",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: MaterialCommunityIcons.cash_plus,
              label: "إيداع",
              gradient: LinearGradient(
                colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => _buildAddMoneyBottomSheet(context),
                );
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: MaterialCommunityIcons.cash_minus,
              label: "سحب",
              gradient: LinearGradient(
                colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              ),
              onTap: () async {
                if (totalAmount > 0) {
                  if (userBankAccount != null &&
                      userBankAccount!.accountNumber.validate().isNotEmpty) {
                    launchScreen(
                      context,
                      WithDrawScreen(
                        bankInfo: userBankAccount!,
                        onTap: () {
                          init();
                        },
                      ),
                    );
                  } else {
                    toast("يرجى إضافة حساب بنكي أولاً");
                    await launchScreen(context, BankInfoScreen());
                    getBankDetail();
                  }
                } else {
                  toast("لا يوجد رصيد كافي للسحب");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "إحصائيات المحفظة",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: "إجمالي الإيداعات",
                  value: "+" + calculateTotalDeposits().toStringAsFixed(2),
                  icon: MaterialCommunityIcons.trending_up,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: "إجمالي السحوبات",
                  value: "-" + calculateTotalWithdrawals().toStringAsFixed(2),
                  icon: MaterialCommunityIcons.trending_down,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  num calculateTotalDeposits() {
    return walletData
        .where((element) => element.type == CREDIT)
        .fold(0, (sum, item) => sum + (item.amount ?? 0));
  }

  num calculateTotalWithdrawals() {
    return walletData
        .where((element) => element.type == DEBIT)
        .fold(0, (sum, item) => sum + (item.amount ?? 0));
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Spacer(),
              Icon(
                MaterialCommunityIcons.chevron_right,
                color: Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "آخر المعاملات",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Icon(
                Icons.history_rounded,
                color: primaryColor,
                size: 20,
              ),
            ],
          ),
          SizedBox(height: 16),
          walletData.isEmpty && !appStore.isLoading
              ? _buildEmptyTransactions()
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: EdgeInsets.all(0),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: walletData.length,
                    shrinkWrap: true,
                    itemBuilder: (_, index) {
                      WalletModel data = walletData[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: _buildTransactionCard(data),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_rounded,
            size: 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            "لا توجد معاملات",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "سيظهر المعاملات هنا",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(WalletModel data) {
    final bool isCredit = data.type == CREDIT;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Transaction details could be shown here in the future
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Enhanced Transaction Type Icon
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                    boxShadow: [
                      BoxShadow(
                        color: (isCredit ? Colors.green : Colors.red)
                            .withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    isCredit ? Icons.add_rounded : Icons.remove_rounded,
                    color:
                        isCredit ? Colors.green.shade700 : Colors.red.shade700,
                    size: 22,
                  ),
                ),
                SizedBox(width: 16),

                // Transaction Details with Better Typography
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.type == DEBIT
                            ? language.moneyDebit
                            : language.moneyDeposited,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded,
                              size: 14, color: Colors.grey.shade500),
                          SizedBox(width: 4),
                          Text(
                            printDate(data.createdAt!),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Enhanced Amount Display
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCredit ? Colors.green.shade50 : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "${isCredit ? "+" : "-"}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isCredit
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                      ),
                      printAmountWidget(
                        amount:
                            '${data.amount!.toStringAsFixed(digitAfterDecimal)}',
                        color: isCredit
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        weight: FontWeight.bold,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Redesigned Add Money Bottom Sheet
  Widget _buildAddMoneyBottomSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      padding: MediaQuery.of(context).viewInsets,
      child: Form(
        key: formKey,
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        height: 5,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Header with Money Icon
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_rounded,
                            color: primaryColor,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          language.addMoney,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                            addMoneyController.clear();
                            currentIndex = -1;
                          },
                          icon: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),

                    // Amount Label
                    Row(
                      children: [
                        Text(
                          language.amount,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        Text(
                          ' *',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Enhanced Amount Field
                    AppTextField(
                      controller: addMoneyController,
                      textFieldType: TextFieldType.PHONE,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*$')),
                      ],
                      errorThisFieldRequired: language.thisFieldRequired,
                      onChanged: (val) {},
                      validator: (String? val) {
                        if (appStore.minAmountToAdd != null &&
                            num.parse(val!) < appStore.minAmountToAdd!) {
                          addMoneyController.text =
                              appStore.minAmountToAdd.toString();
                          addMoneyController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: appStore.minAmountToAdd
                                      .toString()
                                      .length));
                          return "${language.minimum} ${appStore.minAmountToAdd} ${language.required}";
                        } else if (appStore.maxAmountToAdd != null &&
                            num.parse(val!) > appStore.maxAmountToAdd!) {
                          addMoneyController.text =
                              appStore.maxAmountToAdd.toString();
                          addMoneyController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: appStore.maxAmountToAdd
                                      .toString()
                                      .length));
                          return "${language.maximum} ${appStore.maxAmountToAdd} ${language.required}";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: language.amount,
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.monetization_on_rounded,
                            color: primaryColor),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: primaryColor, width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Quick Amounts Label
                    Text(
                      'Quick Amounts',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Enhanced Quick Amount Selection
                    Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      children:
                          appStore.walletPresetTopUpAmount.split('|').map((e) {
                        bool isSelected = currentIndex ==
                            appStore.walletPresetTopUpAmount
                                .split('|')
                                .indexOf(e);
                        return GestureDetector(
                          onTap: () {
                            currentIndex = appStore.walletPresetTopUpAmount
                                .split('|')
                                .indexOf(e);
                            if (appStore.minAmountToAdd != null &&
                                num.parse(e) < appStore.minAmountToAdd!) {
                              addMoneyController.text =
                                  appStore.minAmountToAdd.toString();
                              addMoneyController.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: appStore.minAmountToAdd
                                          .toString()
                                          .length));
                              toast(
                                  "${language.minimum} ${appStore.minAmountToAdd} ${language.required}");
                            } else if (appStore.minAmountToAdd != null &&
                                int.parse(e) < appStore.minAmountToAdd! &&
                                appStore.maxAmountToAdd != null &&
                                int.parse(e) >
                                    appStore.maxAmountToAdd.toString().length) {
                              addMoneyController.text =
                                  appStore.maxAmountToAdd.toString();
                              addMoneyController.selection =
                                  TextSelection.fromPosition(
                                      TextPosition(offset: e.length));
                              toast(
                                  "${language.maximum} ${appStore.maxAmountToAdd} ${language.required}");
                            } else {
                              addMoneyController.text = e;
                              addMoneyController.selection =
                                  TextSelection.fromPosition(
                                      TextPosition(offset: e.length));
                            }
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected ? primaryColor : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(isSelected ? 0.1 : 0.05),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey.shade200),
                            ),
                            child: printAmountWidget(
                              amount: '${e}',
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade800,
                              size: 16,
                              weight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 36),

                    // Enhanced Add Money Button
                    Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0C9869),
                            Color(0xFF1E7145),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            if (addMoneyController.text.isNotEmpty) {
                              if (formKey.currentState!.validate() &&
                                  addMoneyController.text.isNotEmpty) {
                                Navigator.pop(context);
                                bool res = await launchScreen(
                                    context,
                                    PaymentScreen(
                                        amount:
                                            num.parse(addMoneyController.text)),
                                    pageRouteAnimation:
                                        PageRouteAnimation.SlideBottomTop);
                                if (res == true) {
                                  getWalletListApi();
                                }
                                addMoneyController.clear();
                                currentIndex = -1;
                              } else {
                                toast(language.pleaseSelectAmount);
                              }
                            } else {
                              toast(language.pleaseSelectAmount);
                            }
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_circle_outline_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  language.addMoney,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
