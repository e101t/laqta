class Booking {
  final String id;
  final String customerId;
  final String photographerId;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm
  final int duration; // minutes
  final String type; // specialty
  final double price;
  final String currency;
  final String status; // pending, confirmed, rejected, done, canceled
  final BookingPayment payment;
  final BookingLocation location;
  final String? notes;
  final String? chatId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.customerId,
    required this.photographerId,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.price,
    required this.currency,
    required this.status,
    required this.payment,
    required this.location,
    this.notes,
    this.chatId,
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
