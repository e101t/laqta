import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/core/security/secure_storage.dart';
import 'package:luqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:luqta/features/deliveries/data/dtos/delivery_dto.dart';

class FirestoreDeliveriesRemoteDataSource
    implements DeliveriesRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;

  FirestoreDeliveriesRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance);

  CollectionReference<Map<String, dynamic>> get _deliveriesCollection =>
      _firestore.collection('deliveries');

  @override
  Future<DeliveryDto?> getDeliveryByBooking(String bookingId) async {
    final doc = await _secure.guard(
      () => _deliveriesCollection.doc(bookingId).get(),
    );
    if (!doc.exists) {
      return null;
    }
    return DeliveryDto.fromFirestore(doc);
  }

  @override
  Future<void> upsertDelivery(DeliveryDto delivery) async {
    await _secure.guard(
      () => _deliveriesCollection
          .doc(delivery.id)
          .set(delivery.toMap(), SetOptions(merge: true)),
    );
  }

  @override
  Future<String> uploadDeliveryFile({
    required String bookingId,
    required String deliveryId,
    required String filePath,
  }) async {
    final extension = _fileExtension(filePath);
    final fileName =
        'delivery_${DateTime.now().millisecondsSinceEpoch}$extension';
    final storageRef = _storage
        .ref()
        .child('deliveries')
        .child(bookingId)
        .child(deliveryId)
        .child(fileName);

    await _secureStorage.guard(() => storageRef.putFile(File(filePath)));
    return _secureStorage.guard(() => storageRef.getDownloadURL());
  }

  String _fileExtension(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return '.jpg';
    if (lower.endsWith('.mp4') || lower.endsWith('.mov')) return '.mp4';
    if (lower.endsWith('.pdf')) return '.pdf';
    return '';
  }
}
