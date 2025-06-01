# 🚖 تطبيق حجز التاكسي - Taxi Booking App

تطبيق حديث ومتطور لحجز التاكسي مبني بـ Flutter مع تصميم عصري وتجربة مستخدم متميزة.

## 📱 لقطات الشاشة

### الصفحة الرئيسية المحدثة
- تصميم حديث مع انيميشن متقدم
- بطاقات إحصائيات تفاعلية
- شريط بحث محسن
- عروض ترويجية جذابة
- وجهات أخيرة ذكية

## ✨ الميزات الرئيسية

### 🏠 الصفحة الرئيسية (HomeScreen)
- **تصميم متطور**: Material Design 3 مع خلفية متدرجة
- **انيميشن متقدم**: ثلاث وحدات تحكم للحركات المختلفة
- **إحصائيات سريعة**: رحلاتي، نقاطي، محفظتي
- **بحث ذكي**: واجهة بحث تفاعلية مع انيميشن
- **خدمات متنوعة**: عرض الخدمات مع إمكانية الاختيار
- **عروض ترويجية**: بانر عائم للعروض الخاصة
- **وجهات ذكية**: تصنيف تلقائي للأماكن (منزل، عمل، مول، إلخ)
- **إجراءات سريعة**: دعوة الأصدقاء والدعم الفني
- **زر حجز عائم**: وصول سريع لحجز الرحلة

### 🔔 الإشعارات (NotificationScreen)
- **تصنيف متقدم**: 5 فئات (الكل، الرحلات، المدفوعات، الشكاوى، النظام)
- **بحث وفلترة**: بحث نصي وفلتر للإشعارات غير المقروءة
- **إدارة شاملة**: قراءة، حذف، تعليم كمهم
- **إحصائيات تفاعلية**: عرض إحصائيات شاملة
- **تصميم احترافي**: أيقونات ملونة وتنسيق جميل

### 🚗 حجز الرحلات
- **خرائط تفاعلية**: Google Maps مع تتبع الموقع
- **أنواع خدمات متعددة**: سيارات مختلفة للاختيار
- **تقدير الأسعار**: حساب تلقائي للتكلفة
- **تتبع الرحلة**: متابعة الرحلة في الوقت الفعلي

### 💳 المدفوعات
- **طرق دفع متعددة**: 
  - Razorpay
  - Flutterwave
  - PayTabs
  - MyFatoorah
- **محفظة رقمية**: إدارة الرصيد والمعاملات
- **فواتير PDF**: تحميل وعرض الفواتير

### 👤 إدارة الحساب
- **تسجيل الدخول الاجتماعي**: Google و Apple
- **الملف الشخصي**: إدارة البيانات الشخصية
- **الإعدادات**: تخصيص التطبيق
- **التقييمات**: نظام تقييم الرحلات

## 🛠️ التقنيات المستخدمة

### Frontend
- **Flutter**: إطار العمل الأساسي
- **Dart**: لغة البرمجة
- **Material Design 3**: نظام التصميم
- **Custom Animations**: انيميشن مخصص

### State Management
- **MobX**: إدارة الحالة
- **Flutter Bloc**: إدارة الحالة المتقدمة

### Backend & Database
- **Firebase**: 
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Crashlytics
- **REST APIs**: للتكامل مع الخدمات الخارجية

### Maps & Location
- **Google Maps**: عرض الخرائط والمسارات
- **Geolocator**: تحديد الموقع
- **Geocoding**: تحويل الإحداثيات إلى عناوين

### Payments
- **Razorpay**: بوابة دفع هندية
- **Flutterwave**: بوابة دفع أفريقية
- **PayTabs**: بوابة دفع شرق أوسطية
- **MyFatoorah**: بوابة دفع كويتية

### Notifications
- **OneSignal**: إشعارات فورية
- **Firebase Messaging**: رسائل Firebase

### UI/UX Libraries
- **flutter_staggered_animations**: انيميشن متدرج
- **flutter_slidable**: عناصر قابلة للسحب
- **lottie**: انيميشن Lottie
- **cached_network_image**: تحميل الصور المحسن
- **flutter_svg**: دعم SVG

## 📁 هيكل المشروع

```
lib/
├── components/           # المكونات المشتركة
│   ├── ModernAppBar.dart
│   └── SearchLocationComponent.dart
├── model/               # نماذج البيانات
│   ├── ServiceModel.dart
│   ├── RiderModel.dart
│   └── AppSettingModel.dart
├── network/             # طبقة الشبكة
│   └── RestApis.dart
├── screens/             # الشاشات
│   ├── HomeScreen.dart
│   ├── NotificationScreen.dart
│   └── NewEstimateRideListWidget.dart
├── utils/               # الأدوات المساعدة
│   ├── Constants.dart
│   ├── Common.dart
│   ├── Extensions/
│   └── constant/
│       └── app_colors.dart
└── main.dart           # نقطة البداية
```

## 🚀 التثبيت والتشغيل

### المتطلبات
- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / VS Code
- Git

### خطوات التثبيت

1. **استنساخ المشروع**
```bash
git clone [repository-url]
cd taxi-booking-app
```

2. **تثبيت التبعيات**
```bash
flutter pub get
```

3. **إعداد Firebase**
- إنشاء مشروع Firebase جديد
- إضافة ملفات التكوين:
  - `android/app/google-services.json`
  - `ios/Runner/GoogleService-Info.plist`

4. **إعداد Google Maps**
- الحصول على API Key من Google Cloud Console
- إضافة المفتاح في:
  - `android/app/src/main/AndroidManifest.xml`
  - `ios/Runner/AppDelegate.swift`

5. **تشغيل التطبيق**
```bash
flutter run
```

## 🔧 الإعدادات

### متغيرات البيئة
إنشاء ملف `.env` في الجذر:
```env
GOOGLE_MAPS_API_KEY=your_api_key_here
RAZORPAY_KEY=your_razorpay_key
ONESIGNAL_APP_ID=your_onesignal_id
```

### إعدادات Firebase
```dart
// في main.dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## 📱 البناء للإنتاج

### Android
```bash
flutter build apk --release
# أو
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🎨 التخصيص

### الألوان
```dart
// في utils/constant/app_colors.dart
class AppColors {
  static const Color primary = Color(0xFF4CAF50);
  static const Color secondary = Color(0xFFFF9800);
  static const Color background = Color(0xFFF5F5F5);
}
```

### الخطوط
```dart
// في pubspec.yaml
flutter:
  fonts:
    - family: CustomFont
      fonts:
        - asset: fonts/CustomFont-Regular.ttf
        - asset: fonts/CustomFont-Bold.ttf
          weight: 700
```

## 🧪 الاختبار

### تشغيل الاختبارات
```bash
flutter test
```

### اختبار التكامل
```bash
flutter drive --target=test_driver/app.dart
```

## 📊 الأداء

### تحسينات الأداء
- **تحميل البيانات المتوازي**: `Future.wait()`
- **تخزين مؤقت للصور**: `cached_network_image`
- **انيميشن محسن**: `AnimationLimiter`
- **إدارة الذاكرة**: تنظيف وحدات التحكم

### مراقبة الأداء
- **Firebase Crashlytics**: تتبع الأخطاء
- **Performance Monitoring**: مراقبة الأداء
- **Analytics**: تحليل الاستخدام

## 🔒 الأمان

### ميزات الأمان
- **تشفير البيانات**: تشفير المعلومات الحساسة
- **مصادقة آمنة**: Firebase Auth
- **التحقق من الهوية**: OTP verification
- **حماية API**: مفاتيح آمنة

## 🌍 الدعم متعدد اللغات

### اللغات المدعومة
- العربية (الافتراضية)
- الإنجليزية
- الهندية

### إضافة لغة جديدة
```dart
// في pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
```

## 📞 الدعم الفني

### طرق التواصل
- **البريد الإلكتروني**: support@taxiapp.com
- **الهاتف**: +1234567890
- **الدردشة المباشرة**: متاحة في التطبيق

### الأسئلة الشائعة
1. **كيفية إعادة تعيين كلمة المرور؟**
2. **كيفية تغيير طريقة الدفع؟**
3. **كيفية إلغاء الرحلة؟**

## 🔄 التحديثات

### الإصدار الحالي: 2.0.0
- ✅ تطوير الصفحة الرئيسية بالكامل
- ✅ تحسين صفحة الإشعارات
- ✅ انيميشن متقدم
- ✅ تصميم حديث

### التحديثات القادمة: 2.1.0
- 🔄 الوضع الليلي
- 🔄 خرائط تفاعلية محسنة
- 🔄 نظام مكافآت متقدم
- 🔄 دردشة مع السائق

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

## 👥 المساهمون

- **Senior Flutter Developer** - التطوير الأساسي
- **UI/UX Designer** - التصميم والواجهات
- **Backend Developer** - APIs والخدمات

## 🙏 شكر وتقدير

شكر خاص لجميع المكتبات والأدوات مفتوحة المصدر المستخدمة في هذا المشروع.

---

**تم التطوير بـ ❤️ باستخدام Flutter**

**آخر تحديث**: ديسمبر 2024  
**الإصدار**: 2.0.0  
**الحالة**: نشط ومدعوم ✅
