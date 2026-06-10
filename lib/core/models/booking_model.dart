import 'package:laqta/core/utils/legacy_data_compat.dart';

import 'package:laqta/core/utils/firestore_parsers.dart';

class BookingModel {
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
  final PaymentInfo payment;
  final LocationInfo location;
  final DeliverablesInfo deliverables;
  final String? notes;
  final String? chatId;
  final String? deliveryId;
  final String? disputeId;
  final int revisionCount;
  final String? canceledBy;
  final BookingTimeline timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  BookingModel({
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
    this.currency = 'IQD',
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

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = firestoreMap(doc.data());
    final paymentMap = readMapOrNull(data, 'payment') ?? <String, dynamic>{};
    final locationMap = readMapOrNull(data, 'location') ?? <String, dynamic>{};
    final deliverablesMap =
        readMapOrNull(data, 'deliverables') ?? <String, dynamic>{};
    final timelineMap = readMapOrNull(data, 'timeline') ?? <String, dynamic>{};
    return BookingModel(
      id: doc.id,
      customerId: readString(data, 'customerId'),
      photographerId: readString(data, 'photographerId'),
      requestId: readNullableString(data, 'requestId'),
      offerId: readNullableString(data, 'offerId'),
      date: readString(data, 'date'),
      time: readString(data, 'time'),
      duration: readInt(data, 'duration', defaultValue: 60),
      type: readString(data, 'type'),
      price: readDouble(data, 'price'),
      currency: readString(data, 'currency', defaultValue: 'IQD'),
      status: readString(data, 'status', defaultValue: 'pending'),
      payment: PaymentInfo.fromMap(paymentMap),
      location: LocationInfo.fromMap(locationMap),
      deliverables: DeliverablesInfo.fromMap(deliverablesMap),
      notes: readNullableString(data, 'notes'),
      chatId: readNullableString(data, 'chatId'),
      deliveryId: readNullableString(data, 'deliveryId'),
      disputeId: readNullableString(data, 'disputeId'),
      revisionCount: readInt(data, 'revisionCount', defaultValue: 0),
      canceledBy: readNullableString(data, 'canceledBy'),
      timeline: BookingTimeline.fromMap(timelineMap),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'requestId': requestId,
      'offerId': offerId,
      'date': date,
      'time': time,
      'duration': duration,
      'type': type,
      'price': price,
      'currency': currency,
      'status': status,
      'payment': payment.toMap(),
      'location': location.toMap(),
      'deliverables': deliverables.toMap(),
      'notes': notes,
      'chatId': chatId,
      'deliveryId': deliveryId,
      'disputeId': disputeId,
      'revisionCount': revisionCount,
      'canceledBy': canceledBy,
      'timeline': timeline.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  BookingModel copyWith({
    String? status,
    PaymentInfo? payment,
    String? chatId,
    String? deliveryId,
    String? disputeId,
    int? revisionCount,
    String? canceledBy,
    BookingTimeline? timeline,
    DateTime? updatedAt,
  }) {
    return BookingModel(
      id: id,
      customerId: customerId,
      photographerId: photographerId,
      requestId: requestId,
      offerId: offerId,
      date: date,
      time: time,
      duration: duration,
      type: type,
      price: price,
      currency: currency,
      status: status ?? this.status,
      payment: payment ?? this.payment,
      location: location,
      deliverables: deliverables,
      notes: notes,
      chatId: chatId ?? this.chatId,
      deliveryId: deliveryId ?? this.deliveryId,
      disputeId: disputeId ?? this.disputeId,
      revisionCount: revisionCount ?? this.revisionCount,
      canceledBy: canceledBy ?? this.canceledBy,
      timeline: timeline ?? this.timeline,
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
      status: readString(map, 'status', defaultValue: 'pending'),
      intentId: readNullableString(map, 'intentId'),
      amount: readNullableDouble(map, 'amount'),
      paidAt: readDate(map['paidAt']),
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
      lat: readNullableDouble(map, 'lat'),
      lng: readNullableDouble(map, 'lng'),
      text: readNullableString(map, 'text'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'text': text};
  }
}

class DeliverablesInfo {
  final int? photosCount;
  final int? videoMinutes;
  final bool includesEditing;
  final bool includesVideo;
  final String? notes;

  DeliverablesInfo({
    this.photosCount,
    this.videoMinutes,
    this.includesEditing = false,
    this.includesVideo = false,
    this.notes,
  });

  factory DeliverablesInfo.fromMap(Map<String, dynamic> map) {
    return DeliverablesInfo(
      photosCount: readNullableInt(map, 'photosCount'),
      videoMinutes: readNullableInt(map, 'videoMinutes'),
      includesEditing: readBool(map, 'includesEditing'),
      includesVideo: readBool(map, 'includesVideo'),
      notes: readNullableString(map, 'notes'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photosCount': photosCount,
      'videoMinutes': videoMinutes,
      'includesEditing': includesEditing,
      'includesVideo': includesVideo,
      'notes': notes,
    };
  }
}

class BookingTimeline {
  final DateTime? confirmedAt;
  final DateTime? inProgressAt;
  final DateTime? deliveredAt;
  final DateTime? revisionRequestedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;

  BookingTimeline({
    this.confirmedAt,
    this.inProgressAt,
    this.deliveredAt,
    this.revisionRequestedAt,
    this.completedAt,
    this.canceledAt,
  });

  factory BookingTimeline.fromMap(Map<String, dynamic> map) {
    return BookingTimeline(
      confirmedAt: readDate(map['confirmedAt']),
      inProgressAt: readDate(map['inProgressAt']),
      deliveredAt: readDate(map['deliveredAt']),
      revisionRequestedAt: readDate(map['revisionRequestedAt']),
      completedAt: readDate(map['completedAt']),
      canceledAt: readDate(map['canceledAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'confirmedAt': confirmedAt != null
          ? Timestamp.fromDate(confirmedAt!)
          : null,
      'inProgressAt': inProgressAt != null
          ? Timestamp.fromDate(inProgressAt!)
          : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'revisionRequestedAt': revisionRequestedAt != null
          ? Timestamp.fromDate(revisionRequestedAt!)
          : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'canceledAt': canceledAt != null ? Timestamp.fromDate(canceledAt!) : null,
    };
  }
}
