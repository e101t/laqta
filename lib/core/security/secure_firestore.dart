import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'secure_exceptions.dart';

class SecureFirestore {
  final FirebaseFirestore _firestore;
  final Duration timeout;

  const SecureFirestore(
    this._firestore, {
    this.timeout = const Duration(seconds: 12),
  });

  FirebaseFirestore get instance => _firestore;

  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action().timeout(timeout);
    } on TimeoutException {
      throw const SecureException('Request timed out');
    } on FirebaseException catch (e) {
      throw SecureException('Request failed', code: e.code);
    }
  }
}
