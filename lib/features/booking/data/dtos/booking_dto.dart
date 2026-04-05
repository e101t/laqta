import 'package:cloud_firestore/cloud_firestore.dart';

class BookingDto {
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
  final BookingPaymentDto payment;
  final BookingLocationDto location;
  final BookingDeliverablesDto deliverables;
  final String? notes;
  final String? chatId;
  final String? deliveryId;
  final String? disputeId;
  final int revisionCount;
  final String? canceledBy;
  final BookingTimelineDto timeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BookingDto({
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

  factory BookingDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final paymentMap = _readMap(data['payment']);
    final locationMap = _readMap(data['location']);
    final deliverablesMap = _readMap(data['deliverables']);
    final timelineMap = _readMap(data['timeline']);

    return BookingDto(
      id: doc.id,
      customerId: _readString(data, 'customerId'),
      photographerId: _readString(data, 'photographerId'),
      requestId: _readNullableString(data, 'requestId'),
      offerId: _readNullableString(data, 'offerId'),
      date: _readString(data, 'date'),
      time: _readString(data, 'time'),
      duration: _readInt(data, 'duration', fallback: 60),
      type: _readString(data, 'type'),
      price: _readDouble(data, 'price', fallback: 0),
      currency: _readString(data, 'currency', fallback: 'IQD'),
      status: _readString(data, 'status', fallback: 'pending'),
      payment: BookingPaymentDto.fromMap(paymentMap),
      location: BookingLocationDto.fromMap(locationMap),
      deliverables: BookingDeliverablesDto.fromMap(deliverablesMap),
      notes: _readNullableString(data, 'notes'),
      chatId: _readNullableString(data, 'chatId'),
      deliveryId: _readNullableString(data, 'deliveryId'),
      disputeId: _readNullableString(data, 'disputeId'),
      revisionCount: _readInt(data, 'revisionCount', fallback: 0),
      canceledBy: _readNullableString(data, 'canceledBy'),
      timeline: BookingTimelineDto.fromMap(timelineMap),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  static Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
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

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is String) {
      return value;
    }
    return null;
  }

  static int _readInt(
    Map<String, dynamic> data,
    String key, {
    int fallback = 0,
  }) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static int? _readNullableInt(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static double _readDouble(
    Map<String, dynamic> data,
    String key, {
    double fallback = 0,
  }) {
    final value = data[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }

  static bool _readBool(
    Map<String, dynamic> data,
    String key, {
    bool fallback = false,
  }) {
    final value = data[key];
    if (value is bool) {
      return value;
    }
    return fallback;
  }

  static double? _readNullableDouble(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
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

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class BookingPaymentDto {
  final String status;
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  const BookingPaymentDto({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });

  factory BookingPaymentDto.fromMap(Map<String, dynamic> map) {
    return BookingPaymentDto(
      status: BookingDto._readString(map, 'status', fallback: 'pending'),
      intentId: BookingDto._readNullableString(map, 'intentId'),
      amount: BookingDto._readNullableDouble(map, 'amount'),
      paidAt: _readNullableDateTime(map['paidAt']),
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

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class BookingLocationDto {
  final double? lat;
  final double? lng;
  final String? text;

  const BookingLocationDto({this.lat, this.lng, this.text});

  factory BookingLocationDto.fromMap(Map<String, dynamic> map) {
    return BookingLocationDto(
      lat: BookingDto._readNullableDouble(map, 'lat'),
      lng: BookingDto._readNullableDouble(map, 'lng'),
      text: BookingDto._readNullableString(map, 'text'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'text': text};
  }
}

class BookingDeliverablesDto {
  final int? photosCount;
  final int? videoMinutes;
  final bool includesEditing;
  final bool includesVideo;
  final String? notes;

  const BookingDeliverablesDto({
    this.photosCount,
    this.videoMinutes,
    this.includesEditing = false,
    this.includesVideo = false,
    this.notes,
  });

  factory BookingDeliverablesDto.fromMap(Map<String, dynamic> map) {
    return BookingDeliverablesDto(
      photosCount: BookingDto._readNullableInt(map, 'photosCount'),
      videoMinutes: BookingDto._readNullableInt(map, 'videoMinutes'),
      includesEditing:
          BookingDto._readBool(map, 'includesEditing', fallback: false),
      includesVideo: BookingDto._readBool(map, 'includesVideo', fallback: false),
      notes: BookingDto._readNullableString(map, 'notes'),
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

class BookingTimelineDto {
  final DateTime? confirmedAt;
  final DateTime? inProgressAt;
  final DateTime? deliveredAt;
  final DateTime? revisionRequestedAt;
  final DateTime? completedAt;
  final DateTime? canceledAt;

  const BookingTimelineDto({
    this.confirmedAt,
    this.inProgressAt,
    this.deliveredAt,
    this.revisionRequestedAt,
    this.completedAt,
    this.canceledAt,
  });

  factory BookingTimelineDto.fromMap(Map<String, dynamic> map) {
    return BookingTimelineDto(
      confirmedAt: BookingDto._readNullableDateTime(map['confirmedAt']),
      inProgressAt: BookingDto._readNullableDateTime(map['inProgressAt']),
      deliveredAt: BookingDto._readNullableDateTime(map['deliveredAt']),
      revisionRequestedAt: BookingDto._readNullableDateTime(
        map['revisionRequestedAt'],
      ),
      completedAt: BookingDto._readNullableDateTime(map['completedAt']),
      canceledAt: BookingDto._readNullableDateTime(map['canceledAt']),
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
      'canceledAt': canceledAt != null
          ? Timestamp.fromDate(canceledAt!)
          : null,
    };
  }
}
