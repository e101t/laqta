import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:laqta/features/notifications/data/dtos/notification_dto.dart';

class FirestoreNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;
  final BackendFunctionClient _functions;

  FirestoreNotificationsRemoteDataSource({
    LegacyDataStore? firestore,
    BackendFunctionClient? functions,
  }) : _firestore = firestore ?? LegacyDataStore.instance,
       _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
       _functions = functions ?? BackendFunctionClient.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  @override
  Future<List<NotificationDto>> getNotifications(String userId) async {
    final snapshot = await _secure.guard(
      () => _collection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.queryLimit)
          .get(),
    );
    return snapshot.docs.map(NotificationDto.fromFirestore).toList();
  }

  @override
  Future<void> createNotification(NotificationDto notification) async {
    final callable = _functions.httpsCallable('createNotification');
    await callable.call(notification.toMap());
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _secure.guard(
      () => _collection.doc(notificationId).update({'isRead': true}),
    );
  }

  @override
  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.update(_collection.doc(id), {'isRead': true});
    }
    await _secure.guard(() => batch.commit());
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _secure.guard(() => _collection.doc(notificationId).delete());
  }
}
