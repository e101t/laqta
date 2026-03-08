import 'request_deliverables.dart';

class RequestOffer {
  final String id;
  final String requestId;
  final String photographerId;
  final double price;
  final String currency;
  final int deliveryDays;
  final RequestDeliverables deliverables;
  final String? notes;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RequestOffer({
    required this.id,
    required this.requestId,
    required this.photographerId,
    required this.price,
    required this.currency,
    required this.deliveryDays,
    required this.deliverables,
    this.notes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  RequestOffer copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return RequestOffer(
      id: id,
      requestId: requestId,
      photographerId: photographerId,
      price: price,
      currency: currency,
      deliveryDays: deliveryDays,
      deliverables: deliverables,
      notes: notes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
