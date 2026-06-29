class Course {
  final String id;
  final String photographerId;
  final String title;
  final String description;
  final String type; // 'in_person' | 'online'
  final List<String> specialties;
  final double basePrice;
  final String currency;
  final int capacity;
  final int seatsRemaining;
  final List<CourseSession> sessions;
  final CourseLocation? location;
  final String? meetingLink;
  final String? thumbnailUrl;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
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

  bool get isInPerson => type == 'in_person';
  bool get isFull => seatsRemaining <= 0;
}

class CourseSession {
  final String date; // YYYY-MM-DD
  final int startMinutes; // minutes from midnight, 0-1439
  final int endMinutes;

  const CourseSession({
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
  });
}

class CourseLocation {
  final double? lat;
  final double? lng;
  final String? text;

  const CourseLocation({this.lat, this.lng, this.text});
}
