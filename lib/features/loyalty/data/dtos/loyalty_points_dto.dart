import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyPointsDto {
  final String id;
  final int totalPoints;
  final int availablePoints;
  final int usedPoints;
  final List<PointTransactionDto> transactions;
  final String tier;
  final DateTime lastUpdated;

  const LoyaltyPointsDto({
    required this.id,
    required this.totalPoints,
    required this.availablePoints,
    required this.usedPoints,
    required this.transactions,
    required this.tier,
    required this.lastUpdated,
  });

  factory LoyaltyPointsDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final transactionsRaw = data['transactions'];
    final transactionMaps = transactionsRaw is List
        ? transactionsRaw.whereType<Map<dynamic, dynamic>>()
        : const <Map<dynamic, dynamic>>[];
    return LoyaltyPointsDto(
      id: doc.id,
      totalPoints: _readInt(data, 'totalPoints'),
      availablePoints: _readInt(data, 'availablePoints'),
      usedPoints: _readInt(data, 'usedPoints'),
      transactions: transactionMaps
          .map((t) => PointTransactionDto.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
      tier: _readString(data, 'tier', fallback: 'bronze'),
      lastUpdated: _readDateTime(data['lastUpdated']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'usedPoints': usedPoints,
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'tier': tier,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }
}

class PointTransactionDto {
  final String transactionId;
  final int points;
  final String type;
  final String source;
  final String? description;
  final DateTime createdAt;

  const PointTransactionDto({
    required this.transactionId,
    required this.points,
    required this.type,
    required this.source,
    this.description,
    required this.createdAt,
  });

  factory PointTransactionDto.fromMap(Map<String, dynamic> map) {
    return PointTransactionDto(
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
}
