import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:laqta/features/courses/data/dtos/course_dto.dart';

void main() {
  group('CourseSessionDto', () {
    test('round-trips through toMap/fromMap', () {
      const session = CourseSessionDto(
        date: '2026-07-01',
        startMinutes: 540,
        endMinutes: 600,
      );
      final restored = CourseSessionDto.fromMap(session.toMap());

      expect(restored.date, '2026-07-01');
      expect(restored.startMinutes, 540);
      expect(restored.endMinutes, 600);
    });
  });

  group('CourseLocationDto', () {
    test('fromMap handles numeric coercion and missing fields', () {
      final location = CourseLocationDto.fromMap({
        'lat': 33,
        'lng': '44.36',
        'text': 'Baghdad Studio',
      });

      expect(location.lat, 33.0);
      // String lng is intentionally NOT coerced (matches BookingLocationDto's
      // num-only contract) — confirms the documented behavior rather than
      // silently accepting a regression either way.
      expect(location.lng, isNull);
      expect(location.text, 'Baghdad Studio');
    });

    test('toMap round-trips all fields', () {
      const location = CourseLocationDto(lat: 1.5, lng: 2.5, text: 'Here');
      expect(location.toMap(), {'lat': 1.5, 'lng': 2.5, 'text': 'Here'});
    });
  });

  group('CourseDto', () {
    DocumentSnapshot<Map<String, dynamic>> docWith(Map<String, dynamic> data) {
      return DocumentSnapshot<Map<String, dynamic>>('course_1', data);
    }

    test('fromFirestore applies safe fallbacks for a minimal doc', () {
      final dto = CourseDto.fromFirestore(docWith(const {}));

      expect(dto.id, 'course_1');
      expect(dto.photographerId, '');
      expect(dto.type, 'in_person');
      expect(dto.currency, 'IQD');
      expect(dto.capacity, 1);
      expect(dto.seatsRemaining, 0);
      expect(dto.sessions, isEmpty);
      expect(dto.location, isNull);
      expect(dto.isPublished, isFalse);
    });

    test('fromFirestore parses a fully populated course doc', () {
      final dto = CourseDto.fromFirestore(
        docWith({
          'photographerId': 'photog_1',
          'title': 'Wedding Photography Basics',
          'description': 'A 4-week intro course.',
          'type': 'online',
          'specialties': ['Wedding', 'Portrait'],
          'basePrice': 50000,
          'currency': 'IQD',
          'capacity': 10,
          'seatsRemaining': 7,
          'sessions': [
            {'date': '2026-07-01', 'startMinutes': 540, 'endMinutes': 600},
          ],
          'location': null,
          'meetingLink': 'https://meet.example.com/abc',
          'thumbnailUrl': 'https://cdn.example.com/thumb.jpg',
          'isPublished': true,
          'createdAt': Timestamp.fromDate(DateTime.utc(2026, 1, 1)),
          'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
        }),
      );

      expect(dto.photographerId, 'photog_1');
      expect(dto.title, 'Wedding Photography Basics');
      expect(dto.type, 'online');
      expect(dto.specialties, ['Wedding', 'Portrait']);
      expect(dto.basePrice, 50000.0);
      expect(dto.capacity, 10);
      expect(dto.seatsRemaining, 7);
      expect(dto.sessions, hasLength(1));
      expect(dto.sessions.first.startMinutes, 540);
      expect(dto.meetingLink, 'https://meet.example.com/abc');
      expect(dto.isPublished, isTrue);
    });

    test('toMap excludes the id and serializes nested sessions/location', () {
      final dto = CourseDto(
        id: 'course_1',
        photographerId: 'photog_1',
        title: 'Title',
        description: 'Description',
        type: 'in_person',
        specialties: const ['Wedding'],
        basePrice: 1000,
        currency: 'IQD',
        capacity: 5,
        seatsRemaining: 5,
        sessions: const [
          CourseSessionDto(date: '2026-07-01', startMinutes: 0, endMinutes: 60),
        ],
        location: const CourseLocationDto(text: 'Studio'),
        meetingLink: null,
        thumbnailUrl: null,
        isPublished: true,
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 2),
      );

      final map = dto.toMap();

      expect(map.containsKey('id'), isFalse);
      expect(map['sessions'], isA<List<dynamic>>());
      expect((map['sessions'] as List).first, isA<Map<String, dynamic>>());
      expect(map['location'], {'lat': null, 'lng': null, 'text': 'Studio'});
      expect(map['isPublished'], isTrue);
    });
  });
}
