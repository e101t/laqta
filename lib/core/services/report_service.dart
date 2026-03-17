import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:laqta/core/security/secure_firestore.dart';

class ReportService {
  ReportService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('reports');

  Future<void> submitReport({
    required String reporterId,
    required String targetId,
    required String targetType,
    required String targetOwnerId,
    required String reason,
    String? notes,
  }) async {
    await _secure.guard(
      () => _collection.add({
        'reporterId': reporterId,
        'reportedUserId': targetOwnerId,
        'reportedUserName': null,
        'reportType': targetType,
        'reason': reason,
        'details': notes?.trim().isNotEmpty == true
            ? 'targetId=$targetId; ${notes!.trim()}'
            : 'targetId=$targetId',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      }),
    );
  }
}
