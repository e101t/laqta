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

  factory LoyaltyPointsDto.fromJson(Map<String, dynamic> json) {
    final transactionsRaw = json['transactions'];
    final transactionMaps = transactionsRaw is List
        ? transactionsRaw.whereType<Map<dynamic, dynamic>>()
        : const <Map<dynamic, dynamic>>[];
    return LoyaltyPointsDto(
      id: _readString(json, 'id'),
      totalPoints: _readInt(json, 'totalPoints'),
      availablePoints: _readInt(json, 'availablePoints'),
      usedPoints: _readInt(json, 'usedPoints'),
      transactions: transactionMaps
          .map((t) => PointTransactionDto.fromMap(Map<String, dynamic>.from(t)))
          .toList(),
      tier: _readString(json, 'tier', fallback: 'bronze'),
      lastUpdated: _readDateTime(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'availablePoints': availablePoints,
      'usedPoints': usedPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'tier': tier,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  static int _readInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
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
      transactionId: _readString(map, 'transactionId'),
      points: _readInt(map, 'points'),
      type: _readString(map, 'type', fallback: 'earned'),
      source: _readString(map, 'source'),
      description: _readNullableString(map, 'description'),
      createdAt: _readDateTime(map['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'points': points,
      'type': type,
      'source': source,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  static int _readInt(
    Map<String, dynamic> data,
    String key, {
    int fallback = 0,
  }) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}
