class Booking {
  final String id;
  final String customerId;
  final String photographerId;
  final String? requestId;
  final String? offerId;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final int duration; // minutes
  final String type; // specialty
  final double price;
  final String currency;
  final String status; // pending, confirmed, rejected, done, canceled
  final BookingPayment payment;
  final BookingLocation location;
  final BookingDeliverables deliverables;
  final String? notes;
  final String? chatId;
  final String? deliveryId;
  final String? disputeId;
  final int revisionCount;
  final String? canceledBy;
  final BookingTimeline timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.photographerId,
    this.requestId,
    this.offerId,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.price,
    required this.currency,
    required this.status,
    required this.payment,
    required this.location,
    required this.deliverables,
    this.notes,
    this.chatId,
    this.deliveryId,
    this.disputeId,
    this.revisionCount = 0,
    this.canceledBy,
    required this.timeline,
    required this.createdAt,
    required this.updatedAt,
  });
}

class BookingPayment {
  final String status; // pending, succeeded, failed, refunded
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  const BookingPayment({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });
}

class BookingLocation {
  final double? lat;
  final double? lng;
  final String? text;

  const BookingLocation({this.lat, this.lng, this.text});
}

class BookingDeliverables {
  final int? photosCount;
  final int? videoMinutes;
  final bool includesEditing;
  final bool includesVideo;
  final String? notes;

  const BookingDeliverables({
    this.photosCount,
    this.videoMinutes,
    this.includesEditing = false,
    this.includesVideo = false,
    this.notes,
  });
}

class BookingTimeline {
  final DateTime? confirmedAt;
  final DateTime? inProgressAt;
  final DateTime? deliveredAt;
  final DateTime? revisionRequestedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;

  const BookingTimeline({
    this.confirmedAt,
    this.inProgressAt,
    this.deliveredAt,
    this.revisionRequestedAt,
    this.completedAt,
    this.canceledAt,
  });
}
