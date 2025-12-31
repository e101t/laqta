// Loyalty Points System

import 'package:cloud_firestore/cloud_firestore.dart';

// Tier thresholds
const int bronzeThreshold = 0;
const int silverThreshold = 1000;
const int goldThreshold = 3000;
const int platinumThreshold = 5000;

class LoyaltyPoints {
  final String userId;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final List<PointTransaction> transactions;
  final String tier; // bronze, silver, gold, platinum
  final DateTime lastUpdated;

  LoyaltyPoints({
    required this.userId,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    this.transactions = const [],
    this.tier = 'bronze',
    required this.lastUpdated,
  });

  factory LoyaltyPoints.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LoyaltyPoints(
      userId: doc.id,
      totalPoints: data['totalPoints'] ?? 0,
      availablePoints: data['availablePoints'] ?? 0,
      usedPoints: data['usedPoints'] ?? 0,
      transactions:
          (data['transactions'] as List<dynamic>?)
              ?.map((t) => PointTransaction.fromMap(t as Map<String, dynamic>))
              .toList() ??
          [],
      tier: data['tier'] ?? 'bronze',
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'usedPoints': usedPoints,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'tier': tier,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  String getTierName() {
    switch (tier) {
      case 'platinum':
        return 'بلاتينيوم 💎';
      case 'gold':
        return 'ذهبي 🥇';
      case 'silver':
        return 'فضي 🥈';
      default:
        return 'برونزي 🥉';
    }
  }

  double getDiscountPercentage() {
    switch (tier) {
      case 'platinum':
        return 20.0;
      case 'gold':
        return 15.0;
      case 'silver':
        return 10.0;
      default:
        return 5.0;
    }
  }

  int getPointsForNextTier() {
    switch (tier) {
      case 'bronze':
        return silverThreshold - totalPoints;
      case 'silver':
        return goldThreshold - totalPoints;
      case 'gold':
        return platinumThreshold - totalPoints;
      default:
        return 0;
    }
  }

  double getTierProgress() {
    int currentThreshold;
    int nextThreshold;
    switch (tier) {
      case 'bronze':
        currentThreshold = bronzeThreshold;
        nextThreshold = silverThreshold;
        break;
      case 'silver':
        currentThreshold = silverThreshold;
        nextThreshold = goldThreshold;
        break;
      case 'gold':
        currentThreshold = goldThreshold;
        nextThreshold = platinumThreshold;
        break;
      default:
        return 1.0;
    }
    if (nextThreshold == currentThreshold) return 1.0;
    double progress =
        (totalPoints - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }
}

class PointTransaction {
  final String transactionId;
  final int points;
  final String type; // earned, redeemed
  final String source; // booking, referral, review, etc.
  final String? description;
  final DateTime createdAt;

  PointTransaction({
    required this.transactionId,
    required this.points,
    required this.type,
    required this.source,
    this.description,
    required this.createdAt,
  });

  factory PointTransaction.fromMap(Map<String, dynamic> map) {
    return PointTransaction(
      transactionId: map['transactionId'] ?? '',
      points: map['points'] ?? 0,
      type: map['type'] ?? 'earned',
      source: map['source'] ?? '',
      description: map['description'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'points': points,
      'type': type,
      'source': source,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  String getIcon() {
    switch (source) {
      case 'booking':
        return '📅';
      case 'referral':
        return '👥';
      case 'review':
        return '⭐';
      case 'first_booking':
        return '🎉';
      default:
        return '🎁';
    }
  }

  String getTitle() {
    switch (source) {
      case 'booking':
        return 'حجز جديد';
      case 'referral':
        return 'دعوة صديق';
      case 'review':
        return 'كتابة تقييم';
      case 'first_booking':
        return 'أول حجز';
      case 'redeemed':
        return 'استخدام النقاط';
      default:
        return 'نقاط';
    }
  }
}

// Points Rules
class PointsRules {
  static const int bookingCompleted = 100;
  static const int referralSuccess = 200;
  static const int reviewWritten = 50;
  static const int firstBooking = 300;
  static const int profileCompleted = 50;

  static const int pointsToIQD = 100; // 100 points = 1000 IQD
}
