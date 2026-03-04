import 'package:flutter/material.dart';

/// Manual localization for DOZ Taxi.
/// Supports Arabic ('ar') and English ('en').
/// Usage: AppLocalizations.of(context).translate('key')
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(
        context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get languageCode => locale.languageCode;
  bool get isArabic => locale.languageCode == 'ar';

  String translate(String key) {
    final lang = locale.languageCode;
    final map = _strings[key];
    if (map == null) return key;
    return map[lang] ?? map['en'] ?? key;
  }

  // Convenience shorthand
  String t(String key) => translate(key);

  // ── String Map ────────────────────────────────────────────────────────────────

  static const Map<String, Map<String, String>> _strings = {
    // ─── General ────────────────────────────────────────────────────────────────
    'appName': {'ar': 'دوز', 'en': 'DOZ'},
    'ok': {'ar': 'موافق', 'en': 'OK'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel'},
    'save': {'ar': 'حفظ', 'en': 'Save'},
    'delete': {'ar': 'حذف', 'en': 'Delete'},
    'edit': {'ar': 'تعديل', 'en': 'Edit'},
    'close': {'ar': 'إغلاق', 'en': 'Close'},
    'back': {'ar': 'رجوع', 'en': 'Back'},
    'next': {'ar': 'التالي', 'en': 'Next'},
    'retry': {'ar': 'إعادة المحاولة', 'en': 'Retry'},
    'loading': {'ar': 'جاري التحميل...', 'en': 'Loading...'},
    'error': {'ar': 'حدث خطأ', 'en': 'An error occurred'},
    'success': {'ar': 'تمت العملية بنجاح', 'en': 'Success'},
    'noData': {'ar': 'لا توجد بيانات', 'en': 'No data available'},
    'search': {'ar': 'بحث', 'en': 'Search'},
    'filter': {'ar': 'تصفية', 'en': 'Filter'},
    'confirm': {'ar': 'تأكيد', 'en': 'Confirm'},
    'yes': {'ar': 'نعم', 'en': 'Yes'},
    'no': {'ar': 'لا', 'en': 'No'},
    'done': {'ar': 'تم', 'en': 'Done'},
    'skip': {'ar': 'تخطي', 'en': 'Skip'},
    'continue_': {'ar': 'متابعة', 'en': 'Continue'},
    'submit': {'ar': 'إرسال', 'en': 'Submit'},
    'update': {'ar': 'تحديث', 'en': 'Update'},
    'refresh': {'ar': 'تحديث', 'en': 'Refresh'},
    'viewAll': {'ar': 'عرض الكل', 'en': 'View All'},
    'seeMore': {'ar': 'المزيد', 'en': 'See More'},
    'required_': {'ar': 'مطلوب', 'en': 'Required'},
    'optional': {'ar': 'اختياري', 'en': 'Optional'},
    'unknownError': {
      'ar': 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      'en': 'An unexpected error occurred. Please try again.'
    },
    'networkError': {
      'ar': 'تحقق من اتصالك بالإنترنت',
      'en': 'Check your internet connection'
    },
    'serverError': {
      'ar': 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
      'en': 'Server error. Please try again later.'
    },

    // ─── Auth ────────────────────────────────────────────────────────────────────
    'login': {'ar': 'تسجيل الدخول', 'en': 'Login'},
    'register': {'ar': 'إنشاء حساب', 'en': 'Register'},
    'phone': {'ar': 'رقم الهاتف', 'en': 'Phone Number'},
    'email': {'ar': 'البريد الإلكتروني', 'en': 'Email'},
    'password': {'ar': 'كلمة المرور', 'en': 'Password'},
    'otp': {'ar': 'رمز التحقق', 'en': 'OTP'},
    'sendOtp': {'ar': 'إرسال رمز التحقق', 'en': 'Send OTP'},
    'verifyOtp': {'ar': 'تحقق من الرمز', 'en': 'Verify OTP'},
    'forgotPassword': {
      'ar': 'نسيت كلمة المرور؟',
      'en': 'Forgot Password?'
    },
    'loginWithPhone': {
      'ar': 'تسجيل الدخول برقم الهاتف',
      'en': 'Login with Phone'
    },
    'loginWithEmail': {
      'ar': 'تسجيل الدخول بالبريد الإلكتروني',
      'en': 'Login with Email'
    },
    'createAccount': {'ar': 'إنشاء حساب جديد', 'en': 'Create Account'},
    'welcomeBack': {'ar': 'مرحباً بعودتك', 'en': 'Welcome Back'},
    'enterPhone': {
      'ar': 'أدخل رقم هاتفك',
      'en': 'Enter your phone number'
    },
    'enterOtp': {
      'ar': 'أدخل رمز التحقق',
      'en': 'Enter the verification code'
    },
    'otpSent': {
      'ar': 'تم إرسال رمز التحقق إلى',
      'en': 'OTP sent to'
    },
    'otpExpiry': {
      'ar': 'صالح لمدة 5 دقائق',
      'en': 'Valid for 5 minutes'
    },
    'resendOtp': {'ar': 'إعادة إرسال الرمز', 'en': 'Resend OTP'},
    'resendIn': {'ar': 'إعادة الإرسال خلال', 'en': 'Resend in'},
    'invalidOtp': {'ar': 'رمز التحقق غير صحيح', 'en': 'Invalid OTP'},
    'enterName': {'ar': 'أدخل اسمك', 'en': 'Enter your name'},
    'fullName': {'ar': 'الاسم الكامل', 'en': 'Full Name'},
    'selectLanguage': {'ar': 'اختر اللغة', 'en': 'Select Language'},
    'joinAsRider': {
      'ar': 'انضم كراكب',
      'en': 'Join as Rider'
    },
    'joinAsDriver': {
      'ar': 'انضم كسائق',
      'en': 'Join as Driver'
    },
    'alreadyHaveAccount': {
      'ar': 'لديك حساب بالفعل؟',
      'en': 'Already have an account?'
    },
    'dontHaveAccount': {
      'ar': 'ليس لديك حساب؟',
      'en': "Don't have an account?"
    },
    'termsAndConditions': {
      'ar': 'الشروط والأحكام',
      'en': 'Terms & Conditions'
    },
    'privacyPolicy': {
      'ar': 'سياسة الخصوصية',
      'en': 'Privacy Policy'
    },
    'agreeToTerms': {
      'ar': 'أوافق على الشروط والأحكام',
      'en': 'I agree to Terms & Conditions'
    },
    'countryCode': {'ar': 'كود الدولة', 'en': 'Country Code'},

    // ─── Rider ───────────────────────────────────────────────────────────────────
    'whereToGo': {'ar': 'إلى أين تريد الذهاب؟', 'en': 'Where to go?'},
    'setPickup': {'ar': 'تحديد موقع الانطلاق', 'en': 'Set Pickup'},
    'setDropoff': {'ar': 'تحديد وجهتك', 'en': 'Set Destination'},
    'requestRide': {'ar': 'طلب رحلة', 'en': 'Request Ride'},
    'suggestPrice': {
      'ar': 'اقتراح سعر',
      'en': 'Suggest a Price'
    },
    'yourSuggestedPrice': {
      'ar': 'السعر المقترح منك',
      'en': 'Your Suggested Price'
    },
    'findingDrivers': {
      'ar': 'جاري البحث عن السائقين...',
      'en': 'Finding drivers...'
    },
    'waitingForBids': {
      'ar': 'في انتظار عروض الأسعار',
      'en': 'Waiting for bids'
    },
    'bidsReceived': {'ar': 'العروض المستلمة', 'en': 'Bids Received'},
    'acceptBid': {'ar': 'قبول العرض', 'en': 'Accept Bid'},
    'rejectBid': {'ar': 'رفض العرض', 'en': 'Reject Bid'},
    'rideRequested': {'ar': 'تم طلب الرحلة', 'en': 'Ride Requested'},
    'driverOnWay': {
      'ar': 'السائق في الطريق إليك',
      'en': 'Driver on the way'
    },
    'driverArrived': {
      'ar': 'وصل السائق إلى موقعك',
      'en': 'Driver has arrived'
    },
    'rideStarted': {'ar': 'بدأت الرحلة', 'en': 'Ride Started'},
    'rideCompleted': {'ar': 'اكتملت الرحلة', 'en': 'Ride Completed'},
    'cancelRide': {'ar': 'إلغاء الرحلة', 'en': 'Cancel Ride'},
    'cancelReason': {'ar': 'سبب الإلغاء', 'en': 'Cancellation Reason'},
    'confirmCancelRide': {
      'ar': 'هل تريد إلغاء الرحلة؟',
      'en': 'Do you want to cancel this ride?'
    },
    'rate': {'ar': 'تقييم', 'en': 'Rate'},
    'rateDriver': {'ar': 'تقييم السائق', 'en': 'Rate Driver'},
    'tipDriver': {'ar': 'إكرامية للسائق', 'en': 'Tip Driver'},
    'howWasRide': {
      'ar': 'كيف كانت رحلتك؟',
      'en': 'How was your ride?'
    },
    'noRidesYet': {
      'ar': 'لا توجد رحلات بعد',
      'en': 'No rides yet'
    },
    'selectVehicleType': {
      'ar': 'اختر نوع المركبة',
      'en': 'Select Vehicle Type'
    },
    'estimatedFare': {
      'ar': 'السعر المتوقع',
      'en': 'Estimated Fare'
    },
    'priceRange': {'ar': 'نطاق السعر', 'en': 'Price Range'},

    // ─── Driver ──────────────────────────────────────────────────────────────────
    'goOnline': {'ar': 'الذهاب للعمل', 'en': 'Go Online'},
    'goOffline': {'ar': 'إيقاف العمل', 'en': 'Go Offline'},
    'youAreOnline': {'ar': 'أنت متاح الآن', 'en': 'You are online'},
    'youAreOffline': {'ar': 'أنت غير متاح', 'en': 'You are offline'},
    'newRideRequest': {'ar': 'طلب رحلة جديد', 'en': 'New Ride Request'},
    'placeBid': {'ar': 'تقديم عرض سعر', 'en': 'Place Bid'},
    'bidAmount': {'ar': 'مبلغ العرض', 'en': 'Bid Amount'},
    'bidPlaced': {'ar': 'تم تقديم عرضك', 'en': 'Bid placed'},
    'rideAccepted': {'ar': 'تم قبول عرضك', 'en': 'Ride accepted'},
    'navigateToPickup': {
      'ar': 'التنقل إلى موقع الانطلاق',
      'en': 'Navigate to Pickup'
    },
    'arrivedAtPickup': {
      'ar': 'وصلت إلى موقع الانطلاق',
      'en': 'Arrived at Pickup'
    },
    'startRide': {'ar': 'بدء الرحلة', 'en': 'Start Ride'},
    'completeRide': {'ar': 'إنهاء الرحلة', 'en': 'Complete Ride'},
    'rateRider': {'ar': 'تقييم الراكب', 'en': 'Rate Rider'},
    'earnings': {'ar': 'الأرباح', 'en': 'Earnings'},
    'todayEarnings': {
      'ar': 'أرباح اليوم',
      'en': "Today's Earnings"
    },
    'weekEarnings': {
      'ar': 'أرباح الأسبوع',
      'en': 'Weekly Earnings'
    },
    'monthEarnings': {
      'ar': 'أرباح الشهر',
      'en': 'Monthly Earnings'
    },
    'totalEarnings': {
      'ar': 'إجمالي الأرباح',
      'en': 'Total Earnings'
    },
    'ridesCompleted': {
      'ar': 'الرحلات المكتملة',
      'en': 'Completed Rides'
    },
    'acceptanceRate': {
      'ar': 'نسبة القبول',
      'en': 'Acceptance Rate'
    },
    'bidExpired': {
      'ar': 'انتهت صلاحية العرض',
      'en': 'Bid expired'
    },
    'confirmArrival': {
      'ar': 'تأكيد الوصول',
      'en': 'Confirm Arrival'
    },
    'driverStatus': {'ar': 'حالة السائق', 'en': 'Driver Status'},
    'vehicleInfo': {
      'ar': 'معلومات المركبة',
      'en': 'Vehicle Information'
    },

    // ─── Map ─────────────────────────────────────────────────────────────────────
    'currentLocation': {
      'ar': 'موقعك الحالي',
      'en': 'Current Location'
    },
    'searchPlace': {'ar': 'ابحث عن مكان', 'en': 'Search for a place'},
    'recentPlaces': {'ar': 'المواقع الأخيرة', 'en': 'Recent Places'},
    'savedPlaces': {
      'ar': 'المواقع المحفوظة',
      'en': 'Saved Places'
    },
    'home': {'ar': 'المنزل', 'en': 'Home'},
    'work': {'ar': 'العمل', 'en': 'Work'},
    'pickupHere': {
      'ar': 'الانطلاق من هنا',
      'en': 'Pickup Here'
    },
    'dropoffHere': {
      'ar': 'الوصول إلى هنا',
      'en': 'Drop-off Here'
    },
    'estimatedTime': {
      'ar': 'الوقت المتوقع',
      'en': 'Estimated Time'
    },
    'estimatedDistance': {
      'ar': 'المسافة المتوقعة',
      'en': 'Estimated Distance'
    },
    'pickup': {'ar': 'موقع الانطلاق', 'en': 'Pickup'},
    'dropoff': {'ar': 'الوجهة', 'en': 'Destination'},
    'confirmLocation': {
      'ar': 'تأكيد الموقع',
      'en': 'Confirm Location'
    },
    'locationPermission': {
      'ar': 'نحتاج صلاحية الوصول إلى موقعك',
      'en': 'We need access to your location'
    },
    'openSettings': {
      'ar': 'فتح الإعدادات',
      'en': 'Open Settings'
    },
    'searchingLocation': {
      'ar': 'جاري تحديد موقعك...',
      'en': 'Locating you...'
    },
    'driverLocation': {
      'ar': 'موقع السائق',
      'en': "Driver's Location"
    },
    'etaMinutes': {'ar': '{n} دقيقة', 'en': '{n} min away'},

    // ─── Payment ─────────────────────────────────────────────────────────────────
    'wallet': {'ar': 'المحفظة', 'en': 'Wallet'},
    'walletBalance': {'ar': 'رصيد المحفظة', 'en': 'Wallet Balance'},
    'topUp': {'ar': 'شحن الرصيد', 'en': 'Top Up'},
    'paymentMethod': {'ar': 'طريقة الدفع', 'en': 'Payment Method'},
    'cash': {'ar': 'نقداً', 'en': 'Cash'},
    'creditCard': {'ar': 'بطاقة الائتمان', 'en': 'Credit Card'},
    'paymentHistory': {
      'ar': 'سجل المدفوعات',
      'en': 'Payment History'
    },
    'addCard': {'ar': 'إضافة بطاقة', 'en': 'Add Card'},
    'enterAmount': {'ar': 'أدخل المبلغ', 'en': 'Enter Amount'},
    'paymentSuccessful': {
      'ar': 'تمت عملية الدفع بنجاح',
      'en': 'Payment Successful'
    },
    'paymentFailed': {
      'ar': 'فشلت عملية الدفع',
      'en': 'Payment Failed'
    },
    'totalAmount': {'ar': 'المبلغ الإجمالي', 'en': 'Total Amount'},
    'ridePrice': {'ar': 'سعر الرحلة', 'en': 'Ride Price'},
    'platformFee': {'ar': 'رسوم المنصة', 'en': 'Platform Fee'},
    'currency': {'ar': 'دينار أردني', 'en': 'JOD'},
    'topUpSuccess': {
      'ar': 'تم شحن الرصيد بنجاح',
      'en': 'Wallet topped up successfully'
    },
    'insufficientBalance': {
      'ar': 'رصيد المحفظة غير كافٍ',
      'en': 'Insufficient wallet balance'
    },
    'minimumTopUp': {
      'ar': 'الحد الأدنى للشحن 5 دينار',
      'en': 'Minimum top-up is 5 JOD'
    },

    // ─── Profile ─────────────────────────────────────────────────────────────────
    'myProfile': {'ar': 'ملفي الشخصي', 'en': 'My Profile'},
    'editProfile': {
      'ar': 'تعديل الملف الشخصي',
      'en': 'Edit Profile'
    },
    'name': {'ar': 'الاسم', 'en': 'Name'},
    'phoneNumber': {'ar': 'رقم الهاتف', 'en': 'Phone Number'},
    'emailAddress': {
      'ar': 'البريد الإلكتروني',
      'en': 'Email Address'
    },
    'language': {'ar': 'اللغة', 'en': 'Language'},
    'arabic': {'ar': 'العربية', 'en': 'Arabic'},
    'english': {'ar': 'الإنجليزية', 'en': 'English'},
    'darkMode': {'ar': 'الوضع الليلي', 'en': 'Dark Mode'},
    'notifications': {'ar': 'الإشعارات', 'en': 'Notifications'},
    'support': {'ar': 'الدعم الفني', 'en': 'Support'},
    'helpCenter': {'ar': 'مركز المساعدة', 'en': 'Help Center'},
    'about': {'ar': 'عن التطبيق', 'en': 'About'},
    'logout': {'ar': 'تسجيل الخروج', 'en': 'Logout'},
    'deleteAccount': {'ar': 'حذف الحساب', 'en': 'Delete Account'},
    'rideHistory': {'ar': 'سجل الرحلات', 'en': 'Ride History'},
    'confirmLogout': {
      'ar': 'هل تريد تسجيل الخروج؟',
      'en': 'Are you sure you want to logout?'
    },
    'confirmDeleteAccount': {
      'ar': 'هل تريد حذف حسابك نهائياً؟',
      'en': 'Are you sure you want to delete your account?'
    },
    'profileUpdated': {
      'ar': 'تم تحديث الملف الشخصي',
      'en': 'Profile updated successfully'
    },
    'changePhoto': {'ar': 'تغيير الصورة', 'en': 'Change Photo'},
    'takePhoto': {'ar': 'التقاط صورة', 'en': 'Take Photo'},
    'chooseFromGallery': {
      'ar': 'اختيار من المعرض',
      'en': 'Choose from Gallery'
    },

    // ─── Admin ───────────────────────────────────────────────────────────────────
    'dashboard': {'ar': 'لوحة التحكم', 'en': 'Dashboard'},
    'totalRides': {'ar': 'إجمالي الرحلات', 'en': 'Total Rides'},
    'activeRides': {'ar': 'الرحلات النشطة', 'en': 'Active Rides'},
    'totalDrivers': {'ar': 'إجمالي السائقين', 'en': 'Total Drivers'},
    'onlineDrivers': {
      'ar': 'السائقون المتاحون',
      'en': 'Online Drivers'
    },
    'totalRevenue': {'ar': 'إجمالي الإيرادات', 'en': 'Total Revenue'},
    'todayRevenue': {
      'ar': 'إيرادات اليوم',
      'en': "Today's Revenue"
    },
    'manageDrivers': {'ar': 'إدارة السائقين', 'en': 'Manage Drivers'},
    'manageRiders': {'ar': 'إدارة الركاب', 'en': 'Manage Riders'},
    'approveDriver': {'ar': 'الموافقة على السائق', 'en': 'Approve Driver'},
    'blockUser': {'ar': 'حظر المستخدم', 'en': 'Block User'},
    'unblockUser': {'ar': 'رفع الحظر', 'en': 'Unblock User'},
    'revenueReport': {'ar': 'تقرير الإيرادات', 'en': 'Revenue Report'},
    'pendingApproval': {
      'ar': 'في انتظار الموافقة',
      'en': 'Pending Approval'
    },
    'activeUsers': {'ar': 'المستخدمون النشطون', 'en': 'Active Users'},
    'totalUsers': {'ar': 'إجمالي المستخدمين', 'en': 'Total Users'},
    'commissionRate': {'ar': 'نسبة العمولة', 'en': 'Commission Rate'},
    'reportGenerated': {
      'ar': 'تم إنشاء التقرير',
      'en': 'Report generated'
    },

    // ─── Notifications ───────────────────────────────────────────────────────────
    'notificationsTitle': {'ar': 'الإشعارات', 'en': 'Notifications'},
    'newBid': {
      'ar': 'عرض سعر جديد',
      'en': 'New Bid Received'
    },
    'bidAcceptedNotif': {
      'ar': 'تم قبول عرضك',
      'en': 'Your bid was accepted'
    },
    'rideStartedNotif': {
      'ar': 'بدأت رحلتك',
      'en': 'Your ride has started'
    },
    'rideCompletedNotif': {
      'ar': 'اكتملت رحلتك',
      'en': 'Your ride is complete'
    },
    'paymentReceived': {
      'ar': 'تم استلام الدفع',
      'en': 'Payment received'
    },
    'noNotifications': {
      'ar': 'لا توجد إشعارات',
      'en': 'No notifications'
    },
    'markAllRead': {
      'ar': 'تحديد الكل كمقروء',
      'en': 'Mark all as read'
    },

    // ─── Ratings ─────────────────────────────────────────────────────────────────
    'rateYourRide': {'ar': 'قيّم رحلتك', 'en': 'Rate Your Ride'},
    'greatService': {'ar': 'خدمة ممتازة', 'en': 'Great Service'},
    'cleanCar': {'ar': 'سيارة نظيفة', 'en': 'Clean Car'},
    'goodDriving': {'ar': 'قيادة جيدة', 'en': 'Good Driving'},
    'friendlyDriver': {
      'ar': 'سائق ودود',
      'en': 'Friendly Driver'
    },
    'safeRide': {'ar': 'رحلة آمنة', 'en': 'Safe Ride'},
    'onTime': {'ar': 'في الوقت المحدد', 'en': 'On Time'},
    'addComment': {
      'ar': 'إضافة تعليق (اختياري)',
      'en': 'Add a comment (optional)'
    },
    'submitRating': {
      'ar': 'إرسال التقييم',
      'en': 'Submit Rating'
    },
    'yourRating': {'ar': 'تقييمك', 'en': 'Your Rating'},
    'averageRating': {'ar': 'متوسط التقييم', 'en': 'Average Rating'},
    'ratingSubmitted': {
      'ar': 'شكراً على تقييمك!',
      'en': 'Thanks for your rating!'
    },
    'skipRating': {
      'ar': 'تخطي التقييم',
      'en': 'Skip Rating'
    },

    // ─── Ride Status Labels ───────────────────────────────────────────────────────
    'statusPending': {'ar': 'قيد الانتظار', 'en': 'Pending'},
    'statusBidding': {'ar': 'تلقي العروض', 'en': 'Bidding'},
    'statusAccepted': {'ar': 'تم القبول', 'en': 'Accepted'},
    'statusArriving': {'ar': 'السائق في الطريق', 'en': 'Driver Arriving'},
    'statusInProgress': {'ar': 'جارٍ', 'en': 'In Progress'},
    'statusCompleted': {'ar': 'مكتملة', 'en': 'Completed'},
    'statusCancelled': {'ar': 'ملغاة', 'en': 'Cancelled'},

    // ─── Vehicle Types ────────────────────────────────────────────────────────────
    'economy': {'ar': 'اقتصادي', 'en': 'Economy'},
    'comfort': {'ar': 'مريح', 'en': 'Comfort'},
    'suv': {'ar': 'دفع رباعي', 'en': 'SUV'},
    'minibus': {'ar': 'حافلة صغيرة', 'en': 'Minibus'},
    'seats': {'ar': 'مقاعد', 'en': 'seats'},

    // ─── Time & Distance ──────────────────────────────────────────────────────────
    'minutes': {'ar': 'دقيقة', 'en': 'min'},
    'hours': {'ar': 'ساعة', 'en': 'hr'},
    'km': {'ar': 'كم', 'en': 'km'},
    'metersAway': {'ar': 'متر بعيد', 'en': 'meters away'},
    'kmAway': {'ar': 'كم بعيد', 'en': 'km away'},
    'today': {'ar': 'اليوم', 'en': 'Today'},
    'yesterday': {'ar': 'أمس', 'en': 'Yesterday'},
    'justNow': {'ar': 'الآن', 'en': 'Just now'},

    // ─── Errors ───────────────────────────────────────────────────────────────────
    'invalidPhone': {
      'ar': 'رقم الهاتف غير صحيح',
      'en': 'Invalid phone number'
    },
    'invalidEmail': {
      'ar': 'البريد الإلكتروني غير صحيح',
      'en': 'Invalid email address'
    },
    'nameTooShort': {
      'ar': 'الاسم قصير جداً',
      'en': 'Name is too short'
    },
    'priceTooLow': {
      'ar': 'السعر منخفض جداً',
      'en': 'Price is too low'
    },
    'locationNotAvailable': {
      'ar': 'الموقع غير متاح',
      'en': 'Location not available'
    },
    'sessionExpired': {
      'ar': 'انتهت جلستك. يرجى تسجيل الدخول مجدداً.',
      'en': 'Session expired. Please login again.'
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
