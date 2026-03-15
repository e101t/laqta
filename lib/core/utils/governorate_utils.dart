import 'package:luqta/core/constants/app_constants.dart';

String? normalizeGovernorateToArabic(String? governorate) {
  final normalized = governorate?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  final arIndex = AppConstants.iraqiGovernoratesAr.indexOf(normalized);
  if (arIndex != -1) {
    return AppConstants.iraqiGovernoratesAr[arIndex];
  }

  final enIndex = AppConstants.iraqiGovernoratesEn.indexWhere(
    (value) => value.toLowerCase() == normalized.toLowerCase(),
  );
  if (enIndex != -1) {
    return AppConstants.iraqiGovernoratesAr[enIndex];
  }

  return normalized;
}

List<String> governorateVariants(String? governorate) {
  final arabic = normalizeGovernorateToArabic(governorate);
  if (arabic == null || arabic.isEmpty) {
    return const <String>[];
  }

  final variants = <String>{arabic};
  final arIndex = AppConstants.iraqiGovernoratesAr.indexOf(arabic);
  if (arIndex != -1 && arIndex < AppConstants.iraqiGovernoratesEn.length) {
    variants.add(AppConstants.iraqiGovernoratesEn[arIndex]);
  }
  return variants.toList(growable: false);
}
