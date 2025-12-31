// Loyalty Points System

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

  String getTierName() {
    switch (tier) {
      case 'platinum':
        return '????????? ??';
      case 'gold':
        return '???? ??';
      case 'silver':
        return '??? ??';
      default:
        return '?????? ??';
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
    final progress =
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

  String getIcon() {
    switch (source) {
      case 'booking':
        return '??';
      case 'referral':
        return '??';
      case 'review':
        return '?';
      case 'first_booking':
        return '??';
      default:
        return '??';
    }
  }

  String getTitle() {
    switch (source) {
      case 'booking':
        return '??? ????';
      case 'referral':
        return '???? ????';
      case 'review':
        return '????? ?????';
      case 'first_booking':
        return '??? ???';
      case 'redeemed':
        return '??????? ??????';
      default:
        return '????';
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
