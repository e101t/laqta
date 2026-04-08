import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:laqta/features/settings/domain/entities/report_submission.dart';

class FirestoreSettingsRemoteDataSource implements SettingsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final SecureFirestore _secure;

  FirestoreSettingsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _functions = functions ?? FirebaseFunctions.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      _firestore.collection('reports');

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
    if (userId.trim().isEmpty) {
      throw StateError('Missing userId');
    }
    final callable = _functions.httpsCallable('deleteAccountData');
    await callable.call(<String, dynamic>{'userId': userId});
  }
}
