import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:luqta/features/notifications/data/dtos/notification_dto.dart';

class FirestoreNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;
  final FirebaseFunctions _functions;

  FirestoreNotificationsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
      _functions = functions ?? FirebaseFunctions.instance;

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
