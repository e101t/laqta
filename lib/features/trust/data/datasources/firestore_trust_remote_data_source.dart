import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/trust/data/datasources/trust_remote_data_source.dart';
import 'package:luqta/features/trust/data/dtos/trust_stats_dto.dart';

class FirestoreTrustRemoteDataSource implements TrustRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;
  final FirebaseFunctions _functions;

  FirestoreTrustRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  })
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
      _functions = functions ?? FirebaseFunctions.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('trust_stats');

  @override
  Future<TrustStatsDto?> getTrustStats(String photographerId) async {
    final doc = await _secure.guard(
      () => _collection.doc(photographerId).get(),
    );
    if (!doc.exists) {
      return null;
    }
    return TrustStatsDto.fromFirestore(doc);
  }

  @override
  Future<void> incrementReviewStats({
    required String bookingId,
    required String photographerId,
    required double qualityRating,
    required double communicationRating,
    required double onTimeRating,
    required double deliverySpeedRating,
  }) async {
    final callable = _functions.httpsCallable('incrementTrustReviewStats');
    await callable.call({
      'bookingId': bookingId,
      'photographerId': photographerId,
      'qualityRating': qualityRating,
      'communicationRating': communicationRating,
      'onTimeRating': onTimeRating,
      'deliverySpeedRating': deliverySpeedRating,
    });
  }

  @override
  Future<void> incrementCompletedBookings({
    required String bookingId,
    required String photographerId,
  }) async {
    final callable = _functions.httpsCallable('incrementTrustCompletedBookings');
    await callable.call({
      'bookingId': bookingId,
      'photographerId': photographerId,
    });
  }

  @override
  Future<void> incrementCanceledByPhotographer({
    required String bookingId,
    required String photographerId,
  }) async {
    final callable = _functions.httpsCallable(
      'incrementTrustCanceledByPhotographer',
    );
    await callable.call({
      'bookingId': bookingId,
      'photographerId': photographerId,
    });
  }

  @override
  Future<void> incrementDisputesCount({
    required String bookingId,
    required String photographerId,
  }) async {
    final callable = _functions.httpsCallable('incrementTrustDisputesCount');
    await callable.call({
      'bookingId': bookingId,
      'photographerId': photographerId,
    });
  }
}
