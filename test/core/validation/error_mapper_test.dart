import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/validation/error_mapper.dart';

void main() {
  final cases = <int, String>{
    400: 'طلب غير صحيح',
    401: 'انتهت جلستك',
    403: 'ليس لديك صلاحية',
    404: 'المحتوى غير موجود',
    409: 'تعارض في البيانات',
    422: 'يرجى مراجعة الحقول المطلوبة',
    429: 'يرجى الانتظار قبل المحاولة مجدداً',
    500: 'خطأ في الخادم',
    503: 'الخدمة غير متاحة مؤقتاً',
    -1: 'لا يوجد اتصال بالإنترنت',
    599: 'حدث خطأ غير متوقع',
  };

  for (final entry in cases.entries) {
    test('maps status ${entry.key} to Arabic message', () {
      expect(ErrorMapper.messageForStatusCode(entry.key), entry.value);
    });
  }
}
