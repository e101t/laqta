import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:luqta/features/settings/domain/entities/report_submission.dart';

class FirestoreSettingsRemoteDataSource implements SettingsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreSettingsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<void> submitReport(ReportSubmission submission) async {
    final reportData = {
      'reporterId': submission.reporterId,
      'reportedUserId': submission.reportedUserId,
      'reportedUserName': submission.reportedUserName,
      'reportType': submission.reportType,
      'reason': submission.reason,
      'details': submission.details,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    };

    await _secure.guard(() => _reportsCollection.add(reportData));
  }

  @override
  Future<void> deleteUserData(String userId) async {
    await _secure.guard(() => _usersCollection.doc(userId).delete());
  }
}
