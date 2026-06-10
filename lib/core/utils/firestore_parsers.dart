import 'package:laqta/core/utils/legacy_data_compat.dart';

Map<String, dynamic> firestoreMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return <String, dynamic>{};
}

String readString(
  Map<String, dynamic> data,
  String key, {
  String defaultValue = '',
}) {
  final value = data[key];
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

String? readNullableString(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value == null) return null;
  if (value is String) return value;
  return value.toString();
}

int readInt(Map<String, dynamic> data, String key, {int defaultValue = 0}) {
  final value = data[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

int? readNullableInt(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double readDouble(
  Map<String, dynamic> data,
  String key, {
  double defaultValue = 0.0,
}) {
  final value = data[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

double? readNullableDouble(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

bool readBool(
  Map<String, dynamic> data,
  String key, {
  bool defaultValue = false,
}) {
  final value = data[key];
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return defaultValue;
}

DateTime? readDate(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final millis = int.tryParse(value);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}

DateTime readDateTime(
  Map<String, dynamic> data,
  String key, {
  DateTime? defaultValue,
}) {
  return readDate(data[key]) ?? defaultValue ?? DateTime.now();
}

List<String> readStringList(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return const [];
}

List<String>? readStringListOrNull(Map<String, dynamic> data, String key) {
  if (!data.containsKey(key)) return null;
  final value = data[key];
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return null;
}

Map<String, dynamic>? readMapOrNull(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<Map<String, dynamic>> readMapList(Map<String, dynamic> data, String key) {
  final value = data[key];
  if (value is List) {
    return value
        .whereType<Map<Object?, Object?>>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
  }
  return const [];
}

GeoPoint? readGeoPoint(Map<String, dynamic> data, String key) {
  final value = data[key];
  return value is GeoPoint ? value : null;
}
