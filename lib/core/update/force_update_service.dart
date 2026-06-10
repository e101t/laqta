import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:laqta/core/services/backend_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionInfo {
  const AppVersionInfo({
    required this.minimumVersionCode,
    required this.latestVersionCode,
    required this.forceUpdate,
    required this.updateUrl,
    required this.releaseNotesAr,
    required this.releaseNotesEn,
  });

  final int minimumVersionCode;
  final int latestVersionCode;
  final bool forceUpdate;
  final String updateUrl;
  final String releaseNotesAr;
  final String releaseNotesEn;

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      minimumVersionCode: _readInt(json['minimum_version_code']),
      latestVersionCode: _readInt(json['latest_version_code']),
      forceUpdate: json['force_update'] == true,
      updateUrl: (json['update_url'] as String?)?.trim() ?? '',
      releaseNotesAr: (json['release_notes_ar'] as String?)?.trim() ?? '',
      releaseNotesEn: (json['release_notes_en'] as String?)?.trim() ?? '',
    );
  }

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class ForceUpdateResult {
  const ForceUpdateResult({
    required this.currentVersionCode,
    required this.info,
  });

  final int currentVersionCode;
  final AppVersionInfo info;

  bool get isForceRequired =>
      info.forceUpdate || currentVersionCode < info.minimumVersionCode;
  bool get isOptionalAvailable =>
      !isForceRequired && currentVersionCode < info.latestVersionCode;
}

class ForceUpdateService {
  ForceUpdateService({http.Client? client, int? currentVersionCodeOverride})
    : _client = client ?? http.Client(),
      _currentVersionCodeOverride = currentVersionCodeOverride,
      _rethrowErrors = false;

  ForceUpdateService.debug({
    required http.Client client,
    required int currentVersionCodeOverride,
  }) : _client = client,
       _currentVersionCodeOverride = currentVersionCodeOverride,
       _rethrowErrors = true;

  final http.Client _client;
  final int? _currentVersionCodeOverride;
  final bool _rethrowErrors;

  Future<ForceUpdateResult?> checkForUpdate() async {
    try {
      final currentCode =
          _currentVersionCodeOverride ?? await _readCurrentVersionCode();
      final response = await _client
          .get(BackendConfig.apiUri('/app/version'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        return null;
      }
      return ForceUpdateResult(
        currentVersionCode: currentCode,
        info: AppVersionInfo.fromJson(Map<String, dynamic>.from(decoded)),
      );
    } catch (_) {
      if (_rethrowErrors) {
        rethrow;
      }
      return null;
    }
  }

  Future<int> _readCurrentVersionCode() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return int.tryParse(packageInfo.buildNumber) ?? 0;
  }

  void close() => _client.close();
}
