class ErrorMapper {
  ErrorMapper._();

  static String messageForStatusCode(int code) {
    switch (code) {
      case 400:
        return 'طلب غير صحيح';
      case 401:
        return 'انتهت جلستك';
      case 403:
        return 'ليس لديك صلاحية';
      case 404:
        return 'المحتوى غير موجود';
      case 409:
        return 'تعارض في البيانات';
      case 422:
        return 'يرجى مراجعة الحقول المطلوبة';
      case 429:
        return 'يرجى الانتظار قبل المحاولة مجدداً';
      case 500:
        return 'خطأ في الخادم';
      case 503:
        return 'الخدمة غير متاحة مؤقتاً';
      case -1:
        return 'لا يوجد اتصال بالإنترنت';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }
}
