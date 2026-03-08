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

    final snapshots = await Future.wait<QuerySnapshot<Map<String, dynamic>>>([
      _secure.guard(
        () => _bookingsCollection
            .where('photographerId', isEqualTo: photographerId)
            .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
            .get(),
      ),
      _secure.guard(
        () => _offersCollection
            .where('photographerId', isEqualTo: photographerId)
            .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
            .get(),
      ),
      _secure.guard(
        () => _reviewsCollection
            .where('targetId', isEqualTo: photographerId)
            .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
            .get(),
      ),
      _secure.guard(
        () => _reelsCollection
            .where('photographerId', isEqualTo: photographerId)
            .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
            .get(),
      ),
      _secure.guard(
        () => _storiesCollection
            .where('photographerId', isEqualTo: photographerId)
            .where('createdAt', isGreaterThanOrEqualTo: periodTimestamp)
            .get(),
      ),
    ]);

    final bookingsSnapshot = snapshots[0];
    final offersSnapshot = snapshots[1];
    final reviewsSnapshot = snapshots[2];
    final reelsSnapshot = snapshots[3];
    final storiesSnapshot = snapshots[4];

    final completedBookingsDocs = bookingsSnapshot.docs.where((doc) {
      final status = doc.data()['status'];
      return status == 'completed' || status == 'done';
    }).toList();

    final revenue = completedBookingsDocs.fold<double>(0, (total, doc) {
      return total + _toDouble(doc.data()['price']);
    });

    final ratingSum = reviewsSnapshot.docs.fold<double>(0, (total, doc) {
      return total + _toDouble(doc.data()['rating']);
    });
    final avgRating = reviewsSnapshot.docs.isEmpty
        ? 0.0
        : ratingSum / reviewsSnapshot.docs.length;

    final reelViews = reelsSnapshot.docs.fold<int>(0, (total, doc) {
      return total + _toInt(doc.data()['views']);
    });
    final reelEngagement = reelsSnapshot.docs.fold<int>(0, (total, doc) {
      final data = doc.data();
      return total +
          _toInt(data['likes']) +
          _toInt(data['comments']) +
          _toInt(data['shares']);
    });

    final storyViews = storiesSnapshot.docs.length;

    return AnalyticsMetrics(
      totalViews: reelViews + storyViews,
      profileClicks: reelEngagement,
      bookingRequests: offersSnapshot.docs.length,
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
}
