import 'dart:async';

import 'package:laqta/core/utils/legacy_data_compat.dart';

import 'secure_exceptions.dart';

class SecureFirestore {
  final LegacyDataStore _firestore;
  final Duration timeout;

  const SecureFirestore(
    this._firestore, {
    this.timeout = const Duration(seconds: 12),
  });

  LegacyDataStore get instance => _firestore;

  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(timeout);
    } on TimeoutException {
      throw const SecureException('Request timed out');
    } on BackendDataException catch (e) {
      throw SecureException('Request failed', code: e.code);
    }
  }
}
