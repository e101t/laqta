import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/analytics/data/datasources/analytics_remote_data_source.dart';
import 'package:luqta/features/analytics/domain/entities/analytics_metrics.dart';

class FirestoreAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  final FirebaseFirestore _firestore;
  final SecureFirestore _secure;

  FirestoreAnalyticsRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _secure = SecureFirestore(firestore ?? FirebaseFirestore.instance);

  CollectionReference<Map<String, dynamic>> get _bookingsCollection =>
      _firestore.collection('bookings');

  CollectionReference<Map<String, dynamic>> get _offersCollection =>
      _firestore.collection('offers');

  CollectionReference<Map<String, dynamic>> get _reviewsCollection =>
      _firestore.collection('reviews');

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _storiesCollection =>
      _firestore.collection('stories');

  @override
  Future<AnalyticsMetrics> getPhotographerAnalytics({
    required String photographerId,
    required String period,
  }) async {
    final periodStart = _periodStart(period);
    final periodTimestamp = Timestamp.fromDate(periodStart);

    final bookingsDocs = await _loadDocsForPeriod(
      collection: _bookingsCollection,
      field: 'photographerId',
      value: photographerId,
      periodTimestamp: periodTimestamp,
    );
    final offersDocs = await _loadDocsForPeriod(
      collection: _offersCollection,
      field: 'photographerId',
      value: photographerId,
      periodTimestamp: periodTimestamp,
    );
    final reviewsDocs = await _loadDocsForPeriod(
      collection: _reviewsCollection,
      field: 'targetId',
      value: photographerId,
      periodTimestamp: periodTimestamp,
    );
    final reelsDocs = await _loadDocsForPeriod(
      collection: _reelsCollection,
      field: 'photographerId',
      value: photographerId,
      periodTimestamp: periodTimestamp,
    );
    final storiesDocs = await _loadDocsForPeriod(
      collection: _storiesCollection,
      field: 'photographerId',
      value: photographerId,
      periodTimestamp: periodTimestamp,
    );

    final completedBookingsDocs = bookingsDocs.where((data) {
      final status = data['status'];
      return status == 'completed' || status == 'done';
    }).toList();

    final revenue = completedBookingsDocs.fold<double>(0, (total, data) {
      return total + _toDouble(data['price']);
    });

    final ratingSum = reviewsDocs.fold<double>(0, (total, data) {
      return total + _toDouble(data['rating']);
    });
    final avgRating = reviewsDocs.isEmpty
        ? 0.0
        : ratingSum / reviewsDocs.length;

    final reelViews = reelsDocs.fold<int>(0, (total, data) {
      return total + _toInt(data['views']);
    });
    final reelEngagement = reelsDocs.fold<int>(0, (total, data) {
      return total +
          _toInt(data['likes']) +
          _toInt(data['comments']) +
          _toInt(data['shares']);
    });

    final storyViews = storiesDocs.length;

    return AnalyticsMetrics(
      totalViews: reelViews + storyViews,
      profileClicks: reelEngagement,
      bookingRequests: offersDocs.length,
      completedBookings: completedBookingsDocs.length,
      revenue: revenue,
      newFollowers: 0,
      storyViews: storyViews,
      avgRating: avgRating,
    );
  }

  DateTime _periodStart(String period) {
    final now = DateTime.now();
    return switch (period) {
      'today' => DateTime(now.year, now.month, now.day),
      'month' => DateTime(now.year, now.month - 1, now.day),
      'year' => DateTime(now.year - 1, now.month, now.day),
      _ => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(const Duration(days: 7)),
    };
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  Future<List<Map<String, dynamic>>> _loadDocsForPeriod({
    required CollectionReference<Map<String, dynamic>> collection,
    required String field,
    required String value,
    required Timestamp periodTimestamp,
  }) async {
    final periodQuery = await _safeQuery(
      () => collection
          .where(field, isEqualTo: value)
          .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
          .get(),
    );
    final snapshot =
        periodQuery ??
        await _safeQuery(() => collection.where(field, isEqualTo: value).get());
    if (snapshot == null) {
      return const [];
    }

    return snapshot.docs
        .map((doc) => doc.data())
        .where((data) => _isWithinPeriod(data['createdAt'], periodTimestamp))
        .toList();
  }

  Future<QuerySnapshot<Map<String, dynamic>>?> _safeQuery(
    Future<QuerySnapshot<Map<String, dynamic>>> Function() query,
  ) async {
    try {
      return await _secure.guard(query);
    } catch (_) {
      return null;
    }
  }

  bool _isWithinPeriod(dynamic value, Timestamp periodTimestamp) {
    if (value is Timestamp) {
      return value.compareTo(periodTimestamp) >= 0;
    }
    if (value is DateTime) {
      return value.isAfter(periodTimestamp.toDate()) ||
          value.isAtSameMomentAs(periodTimestamp.toDate());
    }
    return true;
  }
}
