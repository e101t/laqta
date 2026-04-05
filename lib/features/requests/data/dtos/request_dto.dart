import 'package:cloud_firestore/cloud_firestore.dart';

class RequestDto {
  final String id;
  final String clientId;
  final String type;
  final String date;
  final String time;
  final String governorate;
  final String? address;
  final double? budgetMin;
  final double? budgetMax;
  final int durationHours;
  final String? style;
  final Map<String, dynamic>? deliverables;
  final String? notes;
  final List<String> referenceImages;
  final String status;
  final int offersCount;
  final String? selectedOfferId;
  final String? selectedPhotographerId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final RequestLocationDto? location;

  const RequestDto({
    required this.id,
    required this.clientId,
    required this.type,
    required this.date,
    required this.time,
    required this.governorate,
    this.address,
    this.budgetMin,
    this.budgetMax,
    required this.durationHours,
    this.style,
    this.deliverables,
    this.notes,
    required this.referenceImages,
    required this.status,
    required this.offersCount,
    this.selectedOfferId,
    this.selectedPhotographerId,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.location,
  });

  factory RequestDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return RequestDto(
      id: doc.id,
      clientId: _readString(data, 'clientId'),
      type: _readString(data, 'type'),
      date: _readString(data, 'date'),
      time: _readString(data, 'time'),
      governorate: _readString(data, 'governorate'),
      address: _readNullableString(data, 'address'),
      budgetMin: _readNullableDouble(data, 'budgetMin'),
      budgetMax: _readNullableDouble(data, 'budgetMax'),
      durationHours: _readInt(data, 'duration', fallback: 1),
      style: _readNullableString(data, 'style'),
      deliverables: _readMap(data['deliverables']),
      notes: _readNullableString(data, 'notes'),
      referenceImages: _readStringList(data['referenceImages']),
      status: _readString(data, 'status', fallback: 'draft'),
      offersCount: _readInt(data, 'offersCount', fallback: 0),
      selectedOfferId: _readNullableString(data, 'selectedOfferId'),
      selectedPhotographerId: _readNullableString(
        data,
        'selectedPhotographerId',
      ),
      expiresAt: _readNullableDateTime(data['expiresAt']),
      location: RequestLocationDto.fromMap(
        _readMap(data['location']) ?? <String, dynamic>{},
      ),
      latitude: _readNullableDouble(data, 'latitude'),
      longitude: _readNullableDouble(data, 'longitude'),
      locationLabel: _readNullableString(data, 'locationLabel'),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  factory RequestDto.fromJson(Map<String, dynamic> json) {
    final location = RequestLocationDto.fromMap(_readMap(json['location']));
    return RequestDto(
      id: _readString(json, 'id'),
      clientId: _readString(json, 'clientId'),
      type: _readString(json, 'type'),
      date: _readString(
        json,
        'date',
        fallback: _readString(json, 'sessionDate'),
      ),
      time: _readString(
        json,
        'time',
        fallback: _readString(json, 'sessionTime'),
      ),
      governorate: _readString(json, 'governorate'),
      address: _readNullableString(json, 'address'),
      budgetMin: _readNullableDouble(json, 'budgetMin'),
      budgetMax: _readNullableDouble(json, 'budgetMax'),
      durationHours: _readInt(
        json,
        'durationHours',
        fallback: _readInt(json, 'duration', fallback: 1),
      ),
      style: _readNullableString(json, 'style'),
      deliverables: _readMap(json['deliverables']),
      notes: _readNullableString(json, 'notes'),
      referenceImages: _readStringList(json['referenceImages']),
      status: _readString(json, 'status', fallback: 'draft'),
      offersCount: _readInt(json, 'offersCount', fallback: 0),
      selectedOfferId: _readNullableString(json, 'selectedOfferId'),
      selectedPhotographerId: _readNullableString(
        json,
        'selectedPhotographerId',
      ),
      expiresAt: _readNullableDateTime(json['expiresAt']),
      latitude: _readNullableDouble(json, 'latitude') ?? location.lat,
      longitude: _readNullableDouble(json, 'longitude') ?? location.lng,
      locationLabel:
          _readNullableString(json, 'locationLabel') ?? location.label,
      location: location,
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'type': type,
      'date': date,
      'time': time,
      'governorate': governorate,
      'address': address,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'duration': durationHours,
      'style': style,
      'deliverables': deliverables,
      'notes': notes,
      'referenceImages': referenceImages,
      'status': status,
      'offersCount': offersCount,
      'selectedOfferId': selectedOfferId,
      'selectedPhotographerId': selectedPhotographerId,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'location': location?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'type': type,
      'date': date,
      'time': time,
      'governorate': governorate,
      'address': address,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'durationHours': durationHours,
      'style': style,
      'deliverables': deliverables,
      'notes': notes,
      'referenceImages': referenceImages,
      'status': status,
      'offersCount': offersCount,
      'selectedOfferId': selectedOfferId,
      'selectedPhotographerId': selectedPhotographerId,
      'expiresAt': expiresAt?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'location': location?.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toBackendCreateJson() {
    return {
      'type': type,
      'sessionDate': date,
      'sessionTime': time,
      'governorate': governorate,
      'address': address,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'durationHours': durationHours,
      'style': style,
      'deliverables': deliverables,
      'notes': notes,
      'referenceImages': referenceImages,
      'expiresAt': expiresAt?.toIso8601String(),
      'location': {
        'lat': latitude ?? location?.lat,
        'lng': longitude ?? location?.lng,
        'label': locationLabel ?? location?.label,
      },
    };
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

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return <String>[];
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}

class RequestLocationDto {
  final double? lat;
  final double? lng;
  final String? label;

  const RequestLocationDto({this.lat, this.lng, this.label});

  factory RequestLocationDto.fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const RequestLocationDto();
    }
    return RequestLocationDto(
      lat: RequestDto._readNullableDouble(map, 'lat'),
      lng: RequestDto._readNullableDouble(map, 'lng'),
      label: RequestDto._readNullableString(map, 'label'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'label': label};
  }
}
