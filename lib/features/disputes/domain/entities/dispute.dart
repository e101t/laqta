class Dispute {
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

  const Dispute({
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

  Dispute copyWith({
    String? status,
    String? resolution,
    DateTime? updatedAt,
    DateTime? closedAt,
    String? decidedBy,
  }) {
    return Dispute(
      id: id,
      bookingId: bookingId,
      requestId: requestId,
      customerId: customerId,
      photographerId: photographerId,
      openedBy: openedBy,
      reason: reason,
      details: details,
      evidenceUrls: evidenceUrls,
      status: status ?? this.status,
      resolution: resolution ?? this.resolution,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      closedAt: closedAt ?? this.closedAt,
      decidedBy: decidedBy ?? this.decidedBy,
    );
  }
}
