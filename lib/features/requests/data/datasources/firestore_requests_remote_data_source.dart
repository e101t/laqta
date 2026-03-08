import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/core/security/secure_storage.dart';
import 'package:luqta/features/booking/data/dtos/booking_dto.dart';
import 'package:luqta/features/requests/data/datasources/requests_remote_data_source.dart';
import 'package:luqta/features/requests/data/dtos/request_dto.dart';
import 'package:luqta/features/requests/data/dtos/request_offer_dto.dart';

class FirestoreRequestsRemoteDataSource implements RequestsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final SecureFirestore _secure;
  final SecureStorage _secureStorage;

  FirestoreRequestsRemoteDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance,
       _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance),
       _secureStorage = SecureStorage(storage ?? FirebaseStorage.instance);

  CollectionReference<Map<String, dynamic>> get _requestsCollection =>
      _firestore.collection('requests');

  CollectionReference<Map<String, dynamic>> get _offersCollection =>
      _firestore.collection('offers');

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  @override
  Future<List<RequestDto>> getMyRequests(String clientId) async {
    if (Firebase.apps.isEmpty) {
      throw StateError('Firebase must be initialized before fetching requests.');
    }
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (kDebugMode) {
      final app = Firebase.app();
      debugPrint(
        'FirestoreRequestsRemoteDataSource:getMyRequests '
        'clientId=$clientId currentAuth=${currentUser?.uid ?? 'null'} '
        'project=${app.name}:${app.options.projectId}',
      );
    }
    if (currentUser == null) {
      throw StateError('Cannot query requests without authenticated user.');
    }
    await currentUser.getIdToken(true);
    if (clientId != currentUser.uid) {
      throw StateError('ClientId mismatch ($clientId vs ${currentUser.uid}).');
    }
    Query<Map<String, dynamic>> query =
        _requestsCollection.where('clientId', isEqualTo: clientId);
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(RequestDto.fromFirestore).toList();
  }

  @override
  Future<List<RequestDto>> getOpenRequests({String? governorate}) async {
    Query<Map<String, dynamic>> query = _requestsCollection.where(
      'status',
      whereIn: const ['published', 'awaiting_offers'],
    );

    if (governorate != null && governorate.isNotEmpty) {
      query = query.where('governorate', isEqualTo: governorate);
    }

    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );

    return snapshot.docs.map(RequestDto.fromFirestore).toList();
  }

  @override
  Future<RequestDto> getRequestById(String requestId) async {
    final doc = await _secure.guard(
      () => _requestsCollection.doc(requestId).get(),
    );
    if (!doc.exists) {
      throw StateError('Request not found');
    }
    return RequestDto.fromFirestore(doc);
  }

  @override
  Future<void> createRequest(RequestDto request) async {
    final docRef = request.id.isEmpty
        ? _requestsCollection.doc()
        : _requestsCollection.doc(request.id);
    await _secure.guard(() => docRef.set(request.toMap()));
  }

  @override
  Future<void> updateRequest(
    String requestId,
    Map<String, dynamic> updates,
  ) async {
    final patched = Map<String, dynamic>.from(updates)
      ..['updatedAt'] = Timestamp.now();
    await _secure.guard(() => _requestsCollection.doc(requestId).update(patched));
  }

  @override
  Future<List<RequestOfferDto>> getOffersForRequest(String requestId) async {
    Query<Map<String, dynamic>> query =
        _offersCollection.where('requestId', isEqualTo: requestId);
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(RequestOfferDto.fromFirestore).toList();
  }

  @override
  Future<List<RequestOfferDto>> getMyOffers(String photographerId) async {
    Query<Map<String, dynamic>> query =
        _offersCollection.where('photographerId', isEqualTo: photographerId);
    if (!kDebugMode) {
      query = query.orderBy('createdAt', descending: true);
    }
    final snapshot = await _secure.guard(
      () => query.limit(AppConstants.queryLimit).get(),
    );
    return snapshot.docs.map(RequestOfferDto.fromFirestore).toList();
  }

  @override
  Future<void> createOffer(RequestOfferDto offer) async {
    final docRef = offer.id.isEmpty
        ? _offersCollection.doc()
        : _offersCollection.doc(offer.id);

    final batch = _firestore.batch();
    batch.set(docRef, offer.toMap());
    batch.update(_requestsCollection.doc(offer.requestId), {
      'offersCount': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });
    await _secure.guard(() => batch.commit());
  }

  @override
  Future<void> acceptOffer({
    required RequestDto request,
    required RequestOfferDto offer,
    required BookingDto booking,
  }) async {
    final batch = _firestore.batch();
    batch.update(_requestsCollection.doc(request.id), {
      'status': 'offer_selected',
      'selectedOfferId': offer.id,
      'selectedPhotographerId': offer.photographerId,
      'updatedAt': Timestamp.now(),
    });
    batch.update(_offersCollection.doc(offer.id), {
      'status': 'accepted',
      'updatedAt': Timestamp.now(),
    });
    batch.set(_bookingsCollection.doc(booking.id), booking.toMap());
    await _secure.guard(() => batch.commit());
  }

  @override
  Future<String> uploadReferenceImage({
    required String requestId,
    required String filePath,
  }) async {
    final extension = _fileExtension(filePath);
    final fileName =
        'ref_${DateTime.now().millisecondsSinceEpoch}$extension';
    final storageRef = _storage
        .ref()
        .child('requests')
        .child(requestId)
        .child('references')
        .child(fileName);

    await _secureStorage.guard(() => storageRef.putFile(File(filePath)));
    return _secureStorage.guard(() => storageRef.getDownloadURL());
  }

  @override
  String generateRequestId() => _requestsCollection.doc().id;

  @override
  String generateOfferId() => _offersCollection.doc().id;

  String _fileExtension(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.png')) return '.png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return '.jpg';
    return '';
  }
}
