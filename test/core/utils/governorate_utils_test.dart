import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/core/utils/governorate_utils.dart';

void main() {
  test('normalizeGovernorateToArabic maps English governorates to Arabic', () {
    expect(normalizeGovernorateToArabic('Dhi Qar'), 'ذي قار');
    expect(normalizeGovernorateToArabic('Baghdad'), 'بغداد');
  });

  test('governorateVariants include Arabic and English forms', () {
    expect(governorateVariants('ذي قار'), ['ذي قار', 'Dhi Qar']);
    expect(governorateVariants('Dhi Qar'), ['ذي قار', 'Dhi Qar']);
  });
}
