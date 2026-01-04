/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'LAQTA';
  static const String appVersion = '1.0.0';

  // Iraqi Governorates
  static const List<String> iraqiGovernoratesAr = [
    'بغداد',
    'البصرة',
    'نينوى',
    'الأنبار',
    'ديالى',
    'ذي قار',
    'النجف',
    'كربلاء',
    'كركوك',
    'بابل',
    'المثنى',
    'القادسية',
    'صلاح الدين',
    'واسط',
    'ميسان',
    'أربيل',
    'دهوك',
    'السليمانية',
  ];

  static const List<String> iraqiGovernoratesEn = [
    'Baghdad',
    'Basra',
    'Nineveh',
    'Anbar',
    'Diyala',
    'Dhi Qar',
    'Najaf',
    'Karbala',
    'Kirkuk',
    'Babylon',
    'Muthanna',
    'Al-Qadisiyyah',
    'Saladin',
    'Wasit',
    'Maysan',
    'Erbil',
    'Dohuk',
    'Sulaymaniyah',
  ];

  // Photography Specialties
  static const List<String> specialtiesAr = [
    'زفاف',
    'خطوبة',
    'مناسبات',
    'عائلي',
    'أطفال',
    'بورتريه',
    'منتجات',
    'طعام',
    'عمارة',
    'رياضة',
    'موضة',
    'طبيعة',
  ];

  static const List<String> specialtiesEn = [
    'Wedding',
    'Engagement',
    'Events',
    'Family',
    'Kids',
    'Portrait',
    'Product',
    'Food',
    'Architecture',
    'Sports',
    'Fashion',
    'Nature',
  ];

  // Booking Status
  static const String bookingPending = 'pending';
  static const String bookingConfirmed = 'confirmed';
  static const String bookingRejected = 'rejected';
  static const String bookingDone = 'done';
  static const String bookingCanceled = 'canceled';

  // Payment Status
  static const String paymentPending = 'pending';
  static const String paymentSucceeded = 'succeeded';
  static const String paymentFailed = 'failed';
  static const String paymentRefunded = 'refunded';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String rolePhotographer = 'photographer';
  static const String roleAdmin = 'admin';

  // Message Types
  static const String messageText = 'text';
  static const String messageImage = 'image';
  static const String messageLocation = 'location';

  // Currency
  static const String currencyIQD = 'IQD';

  // Stripe
  static const String stripePublishableKey =
      'pk_test_YOUR_STRIPE_PUBLISHABLE_KEY';
  static const bool enablePayments = false;

  // Limits
  static const int maxPortfolioImages = 20;
  static const int minPortfolioImages = 3;
  static const int maxImageSizeMB = 5;
  static const int pageSize = 20;
  static const int queryLimit = 50;
  static const int chatMessagesLimit = 100;

  // Durations (milliseconds)
  static const int animationDurationShort = 120;
  static const int animationDurationMedium = 240;
  static const int animationDurationLong = 350;
  static const int splashDuration = 2000;

  // Ratings
  static const double minRatingFilter = 3.0;
  static const double goodRatingFilter = 4.0;
  static const double excellentRatingFilter = 4.5;
  static const double topRatedThreshold = 4.7;

  // OTP
  static const int otpResendSeconds = 60;
  static const int otpLength = 6;

  // Notification Types
  static const String notifBookingCreated = 'BOOKING_CREATED';
  static const String notifBookingStatusChanged = 'BOOKING_STATUS_CHANGED';
  static const String notifNewMessage = 'NEW_MESSAGE';
  static const String notifPaymentSucceeded = 'PAYMENT_SUCCEEDED';
  static const String notifNewOffer = 'NEW_OFFER';

  // SharedPreferences Keys
  static const String keyOnboardingSeen = 'onboardingSeen';
  static const String keyLanguage = 'language';
  static const String keyReduceMotion = 'reduceMotion';
  static const String keyNotificationsEnabled = 'notificationsEnabled';

  // Default Language
  static const String defaultLanguage = 'ar';

  // Report Reasons
  static const List<String> reportReasonsAr = [
    'محتوى غير لائق',
    'صور مسروقة',
    'انتحال شخصية',
    'احتيال',
    'أخرى',
  ];

  static const List<String> reportReasonsEn = [
    'Inappropriate content',
    'Stolen images',
    'Impersonation',
    'Fraud',
    'Other',
  ];
}
