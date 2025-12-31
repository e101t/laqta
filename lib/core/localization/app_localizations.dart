import 'package:flutter/material.dart';
import 'package:luqta/core/localization/ar_translations.dart';
import 'package:luqta/core/localization/en_translations.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': EnTranslations.appName,
      'cancel': EnTranslations.cancel,
      'confirm': EnTranslations.confirm,
      'save': EnTranslations.save,
      'delete': EnTranslations.delete,
      'edit': EnTranslations.edit,
      'search': EnTranslations.search,
      'searchPhotographers': 'Search photographers...',
      'filter': EnTranslations.filter,
      'next': EnTranslations.next,
      'back': EnTranslations.back,
      'skip': EnTranslations.skip,
      'done': EnTranslations.done,
      'loading': EnTranslations.loading,
      'error': EnTranslations.error,
      'retry': EnTranslations.retry,
      'noData': EnTranslations.noData,
      'pressBackAgainToExit': EnTranslations.pressBackAgainToExit,
      'noPhotographers': EnTranslations.noPhotographers,
      'noResults': EnTranslations.noResults,
      'onboardingTitle1': EnTranslations.onboardingTitle1,
      'onboardingDesc1': EnTranslations.onboardingDesc1,
      'onboardingTitle2': EnTranslations.onboardingTitle2,
      'onboardingDesc2': EnTranslations.onboardingDesc2,
      'onboardingTitle3': EnTranslations.onboardingTitle3,
      'onboardingDesc3': EnTranslations.onboardingDesc3,
      'getStarted': EnTranslations.getStarted,
      'welcomeBack': EnTranslations.welcomeBack,
      'welcomeToLuqta': EnTranslations.welcomeToLuqta,
      'authSubtitle': EnTranslations.authSubtitle,
      'signInWithGoogle': EnTranslations.signInWithGoogle,
      'signInWithApple': EnTranslations.signInWithApple,
      'signInWithPhone': EnTranslations.signInWithPhone,
      'phoneNumber': EnTranslations.phoneNumber,
      'verifyOTP': EnTranslations.verifyOTP,
      'enterOTP': EnTranslations.enterOTP,
      'resendCode': EnTranslations.resendCode,
      'verify': EnTranslations.verify,
      'or': EnTranslations.or,
      'googleSignInUnsupported': EnTranslations.googleSignInUnsupported,
      'googleSignInFailed': EnTranslations.googleSignInFailed,
      'appleSignInUnavailable': EnTranslations.appleSignInUnavailable,
      'phoneAuthUnsupported': EnTranslations.phoneAuthUnsupported,
      'phoneAuthSupportInfo': EnTranslations.phoneAuthSupportInfo,
      'phoneNumberRequired': EnTranslations.phoneNumberRequired,
      'verificationFailed': EnTranslations.verificationFailed,
      'phoneAuthError': EnTranslations.phoneAuthError,
      'otpInvalid': EnTranslations.otpInvalid,
      'verificationIdMissing': EnTranslations.verificationIdMissing,
      'otpVerificationFailed': EnTranslations.otpVerificationFailed,
      'resendFailed': EnTranslations.resendFailed,
      'resendError': EnTranslations.resendError,
      'otpSentSuccess': EnTranslations.otpSentSuccess,
      'chooseRole': EnTranslations.chooseRole,
      'customer': EnTranslations.customer,
      'photographer': EnTranslations.photographer,
      'iAmCustomer': EnTranslations.iAmCustomer,
      'iAmPhotographer': EnTranslations.iAmPhotographer,
      'completeProfile': EnTranslations.completeProfile,
      'fullName': EnTranslations.fullName,
      'governorate': EnTranslations.governorate,
      'selectGovernorate': EnTranslations.selectGovernorate,
      'interests': EnTranslations.interests,
      'bio': EnTranslations.bio,
      'specialties': EnTranslations.specialties,
      'basePrice': EnTranslations.basePrice,
      'instagram': EnTranslations.instagram,
      'tiktok': EnTranslations.tiktok,
      'uploadPortfolio': EnTranslations.uploadPortfolio,
      'home': EnTranslations.home,
      'explorePhotographers': EnTranslations.explorePhotographers,
      'bookNow': EnTranslations.bookNow,
      'startingFrom': EnTranslations.startingFrom,
      'viewProfile': EnTranslations.viewProfile,
      'topRated': EnTranslations.topRated,
      'offers': EnTranslations.offers,
      'selectDate': EnTranslations.selectDate,
      'selectTime': EnTranslations.selectTime,
      'confirmBooking': EnTranslations.confirmBooking,
      'chat': EnTranslations.chat,
      'typeMessage': EnTranslations.typeMessage,
      'send': EnTranslations.send,
      'reviews': EnTranslations.reviews,
      'notifications': EnTranslations.notifications,
      'noNotifications': EnTranslations.noNotifications,
      'settings': EnTranslations.settings,
      'language': EnTranslations.language,
      'logout': EnTranslations.logout,
      'deleteAccount': EnTranslations.deleteAccount,
      'enableNotifications': EnTranslations.enableNotifications,
      'reduceMotion': EnTranslations.reduceMotion,
      'privacy': EnTranslations.privacy,
      'terms': EnTranslations.terms,
      'accept': EnTranslations.accept,
      'reject': EnTranslations.reject,
      'dashboard': EnTranslations.dashboard,
      'myBookings': EnTranslations.myBookings,
      'favorites': EnTranslations.favorites,
      'messages': 'Messages',
      'notificationsSection': 'Notifications',
      'appearanceSection': 'Appearance',
      'accessibilitySection': 'Accessibility',
      'legalSection': 'Legal',
      'accountSection': 'Account',
      'darkMode': 'Dark Mode',
      'darkModeSubtitle': 'Enable dark theme',
      'reduceMotionSubtitle': 'Minimize animations for better performance',
      'languageChanged': 'Language changed successfully',
      'availability': EnTranslations.availability,
      'manageSlots': EnTranslations.manageSlots,
      'weeklyTemplate': EnTranslations.weeklyTemplate,
      'popularSpecialties': EnTranslations.popularSpecialties,
      'recentSearches': EnTranslations.recentSearches,
      'clearAll': EnTranslations.clearAll,
      'missingReviewInfo': EnTranslations.missingReviewInfo,
      'payment': EnTranslations.payment,
      'payDeposit': EnTranslations.payDeposit,
      'payFull': EnTranslations.payFull,
      'paymentSuccessful': EnTranslations.paymentSuccessful,
      'paymentFailed': EnTranslations.paymentFailed,
    },
    'ar': {
      'appName': ArTranslations.appName,
      'cancel': ArTranslations.cancel,
      'confirm': ArTranslations.confirm,
      'save': ArTranslations.save,
      'delete': ArTranslations.delete,
      'edit': ArTranslations.edit,
      'search': ArTranslations.search,
      'searchPhotographers': 'ابحث عن مصورين...',
      'filter': ArTranslations.filter,
      'next': ArTranslations.next,
      'back': ArTranslations.back,
      'skip': ArTranslations.skip,
      'done': ArTranslations.done,
      'loading': ArTranslations.loading,
      'error': ArTranslations.error,
      'retry': ArTranslations.retry,
      'noData': ArTranslations.noData,
      'pressBackAgainToExit': ArTranslations.pressBackAgainToExit,
      'noPhotographers': ArTranslations.noPhotographers,
      'noResults': ArTranslations.noResults,
      'onboardingTitle1': ArTranslations.onboardingTitle1,
      'onboardingDesc1': ArTranslations.onboardingDesc1,
      'onboardingTitle2': ArTranslations.onboardingTitle2,
      'onboardingDesc2': ArTranslations.onboardingDesc2,
      'onboardingTitle3': ArTranslations.onboardingTitle3,
      'onboardingDesc3': ArTranslations.onboardingDesc3,
      'getStarted': ArTranslations.getStarted,
      'welcomeBack': ArTranslations.welcomeBack,
      'welcomeToLuqta': ArTranslations.welcomeToLuqta,
      'authSubtitle': ArTranslations.authSubtitle,
      'signInWithGoogle': ArTranslations.signInWithGoogle,
      'signInWithApple': ArTranslations.signInWithApple,
      'signInWithPhone': ArTranslations.signInWithPhone,
      'phoneNumber': ArTranslations.phoneNumber,
      'verifyOTP': ArTranslations.verifyOTP,
      'enterOTP': ArTranslations.enterOTP,
      'resendCode': ArTranslations.resendCode,
      'verify': ArTranslations.verify,
      'or': ArTranslations.or,
      'googleSignInUnsupported': ArTranslations.googleSignInUnsupported,
      'googleSignInFailed': ArTranslations.googleSignInFailed,
      'appleSignInUnavailable': ArTranslations.appleSignInUnavailable,
      'phoneAuthUnsupported': ArTranslations.phoneAuthUnsupported,
      'phoneAuthSupportInfo': ArTranslations.phoneAuthSupportInfo,
      'phoneNumberRequired': ArTranslations.phoneNumberRequired,
      'verificationFailed': ArTranslations.verificationFailed,
      'phoneAuthError': ArTranslations.phoneAuthError,
      'otpInvalid': ArTranslations.otpInvalid,
      'verificationIdMissing': ArTranslations.verificationIdMissing,
      'otpVerificationFailed': ArTranslations.otpVerificationFailed,
      'resendFailed': ArTranslations.resendFailed,
      'resendError': ArTranslations.resendError,
      'otpSentSuccess': ArTranslations.otpSentSuccess,
      'chooseRole': ArTranslations.chooseRole,
      'customer': ArTranslations.customer,
      'photographer': ArTranslations.photographer,
      'iAmCustomer': ArTranslations.iAmCustomer,
      'iAmPhotographer': ArTranslations.iAmPhotographer,
      'completeProfile': ArTranslations.completeProfile,
      'fullName': ArTranslations.fullName,
      'governorate': ArTranslations.governorate,
      'selectGovernorate': ArTranslations.selectGovernorate,
      'interests': ArTranslations.interests,
      'bio': ArTranslations.bio,
      'specialties': ArTranslations.specialties,
      'basePrice': ArTranslations.basePrice,
      'instagram': ArTranslations.instagram,
      'tiktok': ArTranslations.tiktok,
      'uploadPortfolio': ArTranslations.uploadPortfolio,
      'home': ArTranslations.home,
      'explorePhotographers': ArTranslations.explorePhotographers,
      'bookNow': ArTranslations.bookNow,
      'startingFrom': ArTranslations.startingFrom,
      'viewProfile': ArTranslations.viewProfile,
      'topRated': ArTranslations.topRated,
      'offers': ArTranslations.offers,
      'selectDate': ArTranslations.selectDate,
      'selectTime': ArTranslations.selectTime,
      'confirmBooking': ArTranslations.confirmBooking,
      'chat': ArTranslations.chat,
      'typeMessage': ArTranslations.typeMessage,
      'send': ArTranslations.send,
      'reviews': ArTranslations.reviews,
      'notifications': ArTranslations.notifications,
      'noNotifications': ArTranslations.noNotifications,
      'settings': ArTranslations.settings,
      'language': ArTranslations.language,
      'logout': ArTranslations.logout,
      'deleteAccount': ArTranslations.deleteAccount,
      'enableNotifications': ArTranslations.enableNotifications,
      'reduceMotion': ArTranslations.reduceMotion,
      'privacy': ArTranslations.privacy,
      'terms': ArTranslations.terms,
      'accept': ArTranslations.accept,
      'reject': ArTranslations.reject,
      'dashboard': ArTranslations.dashboard,
      'myBookings': ArTranslations.myBookings,
      'favorites': ArTranslations.favorites,
      'messages': 'الرسائل',
      'notificationsSection': 'الإشعارات',
      'appearanceSection': 'المظهر',
      'accessibilitySection': 'إمكانية الوصول',
      'legalSection': 'قانوني',
      'accountSection': 'الحساب',
      'darkMode': 'الوضع الليلي',
      'darkModeSubtitle': 'تفعيل الثيم الداكن',
      'reduceMotionSubtitle': 'تقليل الحركة لأداء أفضل',
      'languageChanged': 'تم تغيير اللغة بنجاح',
      'availability': ArTranslations.availability,
      'manageSlots': ArTranslations.manageSlots,
      'weeklyTemplate': ArTranslations.weeklyTemplate,
      'popularSpecialties': ArTranslations.popularSpecialties,
      'recentSearches': ArTranslations.recentSearches,
      'clearAll': ArTranslations.clearAll,
      'missingReviewInfo': ArTranslations.missingReviewInfo,
      'payment': ArTranslations.payment,
      'payDeposit': ArTranslations.payDeposit,
      'payFull': ArTranslations.payFull,
      'paymentSuccessful': ArTranslations.paymentSuccessful,
      'paymentFailed': ArTranslations.paymentFailed,
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  String get appName => translate('appName');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get searchPhotographers => translate('searchPhotographers');
  String get filter => translate('filter');
  String get next => translate('next');
  String get back => translate('back');
  String get skip => translate('skip');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get retry => translate('retry');
  String get noData => translate('noData');
  String get pressBackAgainToExit => translate('pressBackAgainToExit');
  String get noPhotographers => translate('noPhotographers');
  String get noResults => translate('noResults');
  String get onboardingTitle1 => translate('onboardingTitle1');
  String get onboardingDesc1 => translate('onboardingDesc1');
  String get onboardingTitle2 => translate('onboardingTitle2');
  String get onboardingDesc2 => translate('onboardingDesc2');
  String get onboardingTitle3 => translate('onboardingTitle3');
  String get onboardingDesc3 => translate('onboardingDesc3');
  String get getStarted => translate('getStarted');
  String get welcomeBack => translate('welcomeBack');
  String get welcomeToLuqta => translate('welcomeToLuqta');
  String get authSubtitle => translate('authSubtitle');
  String get signInWithGoogle => translate('signInWithGoogle');
  String get signInWithApple => translate('signInWithApple');
  String get signInWithPhone => translate('signInWithPhone');
  String get phoneNumber => translate('phoneNumber');
  String get verifyOTP => translate('verifyOTP');
  String get enterOTP => translate('enterOTP');
  String get resendCode => translate('resendCode');
  String get verify => translate('verify');
  String get orLabel => translate('or');
  String get googleSignInUnsupported => translate('googleSignInUnsupported');
  String get googleSignInFailed => translate('googleSignInFailed');
  String get appleSignInUnavailable => translate('appleSignInUnavailable');
  String get phoneAuthUnsupported => translate('phoneAuthUnsupported');
  String get phoneAuthSupportInfo => translate('phoneAuthSupportInfo');
  String get phoneNumberRequired => translate('phoneNumberRequired');
  String get verificationFailed => translate('verificationFailed');
  String get phoneAuthError => translate('phoneAuthError');
  String get otpInvalid => translate('otpInvalid');
  String get verificationIdMissing => translate('verificationIdMissing');
  String get otpVerificationFailed => translate('otpVerificationFailed');
  String get resendFailed => translate('resendFailed');
  String get resendError => translate('resendError');
  String get otpSentSuccess => translate('otpSentSuccess');
  String get chooseRole => translate('chooseRole');
  String get customer => translate('customer');
  String get photographer => translate('photographer');
  String get iAmCustomer => translate('iAmCustomer');
  String get iAmPhotographer => translate('iAmPhotographer');
  String get completeProfile => translate('completeProfile');
  String get fullName => translate('fullName');
  String get governorate => translate('governorate');
  String get selectGovernorate => translate('selectGovernorate');
  String get interests => translate('interests');
  String get bio => translate('bio');
  String get specialties => translate('specialties');
  String get basePrice => translate('basePrice');
  String get instagram => translate('instagram');
  String get tiktok => translate('tiktok');
  String get uploadPortfolio => translate('uploadPortfolio');
  String get home => translate('home');
  String get explorePhotographers => translate('explorePhotographers');
  String get bookNow => translate('bookNow');
  String get startingFrom => translate('startingFrom');
  String get viewProfile => translate('viewProfile');
  String get topRated => translate('topRated');
  String get offers => translate('offers');
  String get selectDate => translate('selectDate');
  String get selectTime => translate('selectTime');
  String get confirmBooking => translate('confirmBooking');
  String get chat => translate('chat');
  String get typeMessage => translate('typeMessage');
  String get send => translate('send');
  String get reviews => translate('reviews');
  String get notifications => translate('notifications');
  String get noNotifications => translate('noNotifications');
  String get settings => translate('settings');
  String get language => translate('language');
  String get logout => translate('logout');
  String get deleteAccount => translate('deleteAccount');
  String get enableNotifications => translate('enableNotifications');
  String get reduceMotion => translate('reduceMotion');
  String get privacy => translate('privacy');
  String get terms => translate('terms');
  String get accept => translate('accept');
  String get reject => translate('reject');
  String get dashboard => translate('dashboard');
  String get myBookings => translate('myBookings');
  String get favorites => translate('favorites');
  String get messages => translate('messages');
  String get notificationsSection => translate('notificationsSection');
  String get appearanceSection => translate('appearanceSection');
  String get accessibilitySection => translate('accessibilitySection');
  String get legalSection => translate('legalSection');
  String get accountSection => translate('accountSection');
  String get darkMode => translate('darkMode');
  String get darkModeSubtitle => translate('darkModeSubtitle');
  String get reduceMotionSubtitle => translate('reduceMotionSubtitle');
  String get languageChanged => translate('languageChanged');
  String get availability => translate('availability');
  String get manageSlots => translate('manageSlots');
  String get weeklyTemplate => translate('weeklyTemplate');
  String get popularSpecialties => translate('popularSpecialties');
  String get recentSearches => translate('recentSearches');
  String get clearAll => translate('clearAll');
  String get missingReviewInfo => translate('missingReviewInfo');
  String get payment => translate('payment');
  String get payDeposit => translate('payDeposit');
  String get payFull => translate('payFull');
  String get paymentSuccessful => translate('paymentSuccessful');
  String get paymentFailed => translate('paymentFailed');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
