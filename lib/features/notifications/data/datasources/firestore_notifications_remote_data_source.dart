import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/features/notifications/data/datasources/notifications_remote_data_source.dart';
import 'package:luqta/features/notifications/data/dtos/notification_dto.dart';

class FirestoreNotificationsRemoteDataSource
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore _firestore;

  FirestoreNotificationsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('notifications');

  @override
  Future<List<NotificationDto>> getNotifications(String userId) async {
    final snapshot = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map(NotificationDto.fromFirestore).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _collection.doc(notificationId).update({'isRead': true});
  }

  @override
  Future<void> markAllAsRead(List<String> notificationIds) async {
    if (notificationIds.isEmpty) return;
    final batch = _firestore.batch();
    for (final id in notificationIds) {
      batch.update(_collection.doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _collection.doc(notificationId).delete();
  }
}
