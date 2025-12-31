import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
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
  final PaymentInfo payment;
  final LocationInfo location;
  final String? notes;
  final String? chatId;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
    required this.id,
    required this.customerId,
    required this.photographerId,
    required this.date,
    required this.time,
    required this.duration,
    required this.type,
    required this.price,
    this.currency = 'IQD',
    required this.status,
    required this.payment,
    required this.location,
    this.notes,
    this.chatId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      customerId: data['customerId'] ?? '',
      photographerId: data['photographerId'] ?? '',
      date: data['date'] ?? '',
      time: data['time'] ?? '',
      duration: data['duration'] ?? 60,
      type: data['type'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      currency: data['currency'] ?? 'IQD',
      status: data['status'] ?? 'pending',
      payment: PaymentInfo.fromMap(data['payment'] ?? {}),
      location: LocationInfo.fromMap(data['location'] ?? {}),
      notes: data['notes'],
      chatId: data['chatId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'date': date,
      'time': time,
      'duration': duration,
      'type': type,
      'price': price,
      'currency': currency,
      'status': status,
      'payment': payment.toMap(),
      'location': location.toMap(),
      'notes': notes,
      'chatId': chatId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookingModel copyWith({
    String? status,
    PaymentInfo? payment,
    String? chatId,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      photographerId: photographerId,
      date: date,
      time: time,
      duration: duration,
      type: type,
      price: price,
      currency: currency,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      location: location,
      notes: notes,
      chatId: chatId ?? this.chatId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class PaymentInfo {
  final String status; // pending, succeeded, failed, refunded
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  PaymentInfo({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      status: map['status'] ?? 'pending',
      intentId: map['intentId'],
      amount: map['amount']?.toDouble(),
      paidAt: (map['paidAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'intentId': intentId,
      'amount': amount,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
    };
  }

  PaymentInfo copyWith({
    String? status,
    String? intentId,
    double? amount,
    DateTime? paidAt,
  }) {
    return PaymentInfo(
      status: status ?? this.status,
      intentId: intentId ?? this.intentId,
      amount: amount ?? this.amount,
      paidAt: paidAt ?? this.paidAt,
    );
  }
}

class LocationInfo {
  final double? lat;
  final double? lng;
  final String? text;

  LocationInfo({this.lat, this.lng, this.text});

  factory LocationInfo.fromMap(Map<String, dynamic> map) {
    return LocationInfo(
      lat: map['lat']?.toDouble(),
      lng: map['lng']?.toDouble(),
      text: map['text'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'text': text};
  }
}
