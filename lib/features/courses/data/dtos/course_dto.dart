import 'package:laqta/core/utils/legacy_data_compat.dart';

class CourseDto {
  final String id;
  final String photographerId;
  final String title;
  final String description;
  final String type;
  final List<String> specialties;
  final double basePrice;
  final String currency;
  final int capacity;
  final int seatsRemaining;
  final List<CourseSessionDto> sessions;
  final CourseLocationDto? location;
  final String? meetingLink;
  final String? thumbnailUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseDto({
    required this.id,
    required this.photographerId,
    required this.title,
    required this.description,
    required this.type,
    required this.specialties,
    required this.basePrice,
    required this.currency,
    required this.capacity,
    required this.seatsRemaining,
    required this.sessions,
    this.location,
    this.meetingLink,
    this.thumbnailUrl,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final locationMap = data['location'];
    final sessionsList = data['sessions'];

    return CourseDto(
      id: doc.id,
      photographerId: _readString(data, 'photographerId'),
      title: _readString(data, 'title'),
      description: _readString(data, 'description'),
      type: _readString(data, 'type', fallback: 'in_person'),
      specialties: _readStringList(data['specialties']),
      basePrice: _readDouble(data, 'basePrice', fallback: 0),
      currency: _readString(data, 'currency', fallback: 'IQD'),
      capacity: _readInt(data, 'capacity', fallback: 1),
      seatsRemaining: _readInt(data, 'seatsRemaining', fallback: 0),
      sessions: sessionsList is List
          ? sessionsList
                .whereType<Map<dynamic, dynamic>>()
                .map(
                  (item) => CourseSessionDto.fromMap(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
      location: locationMap is Map
          ? CourseLocationDto.fromMap(Map<String, dynamic>.from(locationMap))
          : null,
      meetingLink: _readNullableString(data, 'meetingLink'),
      thumbnailUrl: _readNullableString(data, 'thumbnailUrl'),
      isPublished: _readBool(data, 'isPublished', fallback: false),
      createdAt: _readDateTime(data['createdAt']),
      updatedAt: _readDateTime(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'photographerId': photographerId,
      'title': title,
      'description': description,
      'type': type,
      'specialties': specialties,
      'basePrice': basePrice,
      'currency': currency,
      'capacity': capacity,
      'seatsRemaining': seatsRemaining,
      'sessions': sessions.map((s) => s.toMap()).toList(),
      'location': location?.toMap(),
      'meetingLink': meetingLink,
      'thumbnailUrl': thumbnailUrl,
      'isPublished': isPublished,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static String? _readNullableString(Map<String, dynamic> data, String key) {
    final value = data[key];
    return value is String ? value : null;
  }

  static int _readInt(
    Map<String, dynamic> data,
    String key, {
    int fallback = 0,
  }) {
    final value = data[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double _readDouble(
    Map<String, dynamic> data,
    String key, {
    double fallback = 0,
  }) {
    final value = data[key];
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return fallback;
  }

  static bool _readBool(
    Map<String, dynamic> data,
    String key, {
    bool fallback = false,
  }) {
    final value = data[key];
    return value is bool ? value : fallback;
  }

  static List<String> _readStringList(dynamic value) {
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return const [];
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

class CourseSessionDto {
  final String date;
  final int startMinutes;
  final int endMinutes;

  const CourseSessionDto({
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
  });

  factory CourseSessionDto.fromMap(Map<String, dynamic> map) {
    return CourseSessionDto(
      date: CourseDto._readString(map, 'date'),
      startMinutes: CourseDto._readInt(map, 'startMinutes'),
      endMinutes: CourseDto._readInt(map, 'endMinutes'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'date': date, 'startMinutes': startMinutes, 'endMinutes': endMinutes};
  }
}

class CourseLocationDto {
  final double? lat;
  final double? lng;
  final String? text;

  const CourseLocationDto({this.lat, this.lng, this.text});

  factory CourseLocationDto.fromMap(Map<String, dynamic> map) {
    final lat = map['lat'];
    final lng = map['lng'];
    return CourseLocationDto(
      lat: lat is num ? lat.toDouble() : null,
      lng: lng is num ? lng.toDouble() : null,
      text: CourseDto._readNullableString(map, 'text'),
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'text': text};
  }
}
