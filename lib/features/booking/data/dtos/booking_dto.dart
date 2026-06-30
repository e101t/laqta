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

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final paymentMap = _readMap(json['payment']);
    final locationMap = _readMap(json['location']);
    final deliverablesMap = _readMap(json['deliverables']);
    final timelineMap = _readMap(json['timeline']);

    return BookingDto(
      id: _readString(json, 'id'),
      customerId: _readString(json, 'customerId'),
      photographerId: _readString(json, 'photographerId'),
      requestId: _readNullableString(json, 'requestId'),
      offerId: _readNullableString(json, 'offerId'),
      date: _readString(json, 'date'),
      time: _readString(json, 'time'),
      duration: _readInt(json, 'duration', fallback: 60),
      type: _readString(json, 'type'),
      price: _readDouble(json, 'price', fallback: 0),
      currency: _readString(json, 'currency', fallback: 'IQD'),
      status: _readString(json, 'status', fallback: 'pending'),
      payment: BookingPaymentDto.fromMap(paymentMap),
      location: BookingLocationDto.fromMap(locationMap),
      deliverables: BookingDeliverablesDto.fromMap(deliverablesMap),
      notes: _readNullableString(json, 'notes'),
      chatId: _readNullableString(json, 'chatId'),
      deliveryId: _readNullableString(json, 'deliveryId'),
      disputeId: _readNullableString(json, 'disputeId'),
      revisionCount: _readInt(json, 'revisionCount', fallback: 0),
      canceledBy: _readNullableString(json, 'canceledBy'),
      timeline: BookingTimelineDto.fromMap(timelineMap),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
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
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value);
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
      paidAt: BookingDto._readNullableDateTime(map['paidAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'intentId': intentId,
      'amount': amount,
      'paidAt': paidAt?.toIso8601String(),
    };
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
      includesEditing: BookingDto._readBool(
        map,
        'includesEditing',
        fallback: false,
      ),
      includesVideo: BookingDto._readBool(
        map,
        'includesVideo',
        fallback: false,
      ),
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
      'confirmedAt': confirmedAt?.toIso8601String(),
      'inProgressAt': inProgressAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'revisionRequestedAt': revisionRequestedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'canceledAt': canceledAt?.toIso8601String(),
    };
  }
}
