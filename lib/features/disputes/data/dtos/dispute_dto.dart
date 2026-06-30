class DisputeDto {
  final String id;
  final String bookingId;
  final String? requestId;
  final String customerId;
  final String photographerId;
  final String openedBy;
  final String reason;
  final String details;
  final List<String> evidenceUrls;
  final String status;
  final String? resolution;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? closedAt;
  final String? decidedBy;

  const DisputeDto({
    required this.id,
    required this.bookingId,
    this.requestId,
    required this.customerId,
    required this.photographerId,
    required this.openedBy,
    required this.reason,
    required this.details,
    required this.evidenceUrls,
    required this.status,
    this.resolution,
    required this.createdAt,
    required this.updatedAt,
    this.closedAt,
    this.decidedBy,
  });

  factory DisputeDto.fromJson(Map<String, dynamic> json) {
    return DisputeDto(
      id: _readString(json, 'id'),
      bookingId: _readString(json, 'bookingId'),
      requestId: _readNullableString(json, 'requestId'),
      customerId: _readString(json, 'customerId'),
      photographerId: _readString(json, 'photographerId'),
      openedBy: _readString(json, 'openedBy'),
      reason: _readString(json, 'reason'),
      details: _readString(json, 'details'),
      evidenceUrls: _readStringList(json['evidenceUrls']),
      status: _readString(json, 'status', fallback: 'open'),
      resolution: _readNullableString(json, 'resolution'),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
      closedAt: _readNullableDateTime(json['closedAt']),
      decidedBy: _readNullableString(json, 'decidedBy'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'requestId': requestId,
      'customerId': customerId,
      'photographerId': photographerId,
      'openedBy': openedBy,
      'reason': reason,
      'details': details,
      'evidenceUrls': evidenceUrls,
      'status': status,
      'resolution': resolution,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'closedAt': closedAt?.toIso8601String(),
      'decidedBy': decidedBy,
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

  static List<String> _readStringList(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value);
    if (value is DateTime) return value;
    return null;
  }
}
