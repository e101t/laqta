import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/core/services/backend_media_service.dart';
import 'package:laqta/core/security/secure_firestore.dart';
import 'package:laqta/features/deliveries/data/datasources/deliveries_remote_data_source.dart';
import 'package:laqta/features/deliveries/data/dtos/delivery_dto.dart';

class FirestoreDeliveriesRemoteDataSource
    implements DeliveriesRemoteDataSource {
  final LegacyDataStore _firestore;
  final SecureFirestore _secure;
  final BackendMediaService _backendMedia;

  FirestoreDeliveriesRemoteDataSource({
    LegacyDataStore? firestore,
    BackendMediaService? backendMediaService,
  }) : _firestore = firestore ?? LegacyDataStore.instance,
       _secure = SecureFirestore(firestore ?? LegacyDataStore.instance),
       _backendMedia = backendMediaService ?? BackendMediaService();

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
  }) {
    return _backendMedia.uploadFile(
      entityType: 'delivery',
      entityId: bookingId,
      filePath: filePath,
      publicContent: false,
    );
  }
}
