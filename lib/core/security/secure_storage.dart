import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';

import 'secure_exceptions.dart';

class SecureStorage {
  final FirebaseStorage _storage;
  final Duration timeout;

  const SecureStorage(
    this._storage, {
    this.timeout = const Duration(seconds: 20),
  });

  FirebaseStorage get instance => _storage;

  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(timeout);
    } on TimeoutException {
      throw const SecureException('Upload timed out');
    } on FirebaseException catch (e) {
      throw SecureException('Storage request failed', code: e.code);
    }
  }
}
