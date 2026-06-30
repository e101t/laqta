class RequestOfferDto {
  final String id;
  final String requestId;
  final String photographerId;
  final double price;
  final String currency;
  final int deliveryDays;
  final Map<String, dynamic>? deliverables;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestOfferDto({
    required this.id,
    required this.requestId,
    required this.photographerId,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    this.deliverables,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RequestOfferDto.fromJson(Map<String, dynamic> json) {
    return RequestOfferDto(
      id: json['id'] as String,
      requestId: json['requestId'] as String,
      photographerId: json['photographerId'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      deliveryDays: json['deliveryDays'] as int,
      deliverables: json['deliverables'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requestId': requestId,
      'photographerId': photographerId,
      'price': price,
      'currency': currency,
      'deliveryDays': deliveryDays,
      'deliverables': deliverables,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
