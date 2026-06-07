import 'package:laqta/core/utils/legacy_data_compat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/requests/data/dtos/request_dto.dart';

void main() {
  test('RequestDto.toMap includes location fields', () {
    final now = DateTime(2026, 1, 28, 10, 0);
    final dto = RequestDto(
      id: 'req1',
      clientId: 'user1',
      type: 'Wedding',
      date: '2026-02-01',
      time: '10:00',
      governorate: 'Baghdad',
      address: 'Address',
      budgetMin: 100,
      budgetMax: 200,
      durationHours: 2,
      style: 'Classic',
      deliverables: const {'photosCount': 10},
      notes: 'Notes',
      referenceImages: const [],
      status: 'draft',
      offersCount: 0,
      selectedOfferId: null,
      selectedPhotographerId: null,
      expiresAt: now.add(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
      latitude: 33.3128,
      longitude: 44.3615,
      locationLabel: 'Baghdad',
      location: const RequestLocationDto(
        lat: 33.3128,
        lng: 44.3615,
        label: 'Baghdad',
      ),
    );

    final map = dto.toMap();

    expect(map['latitude'], 33.3128);
    expect(map['longitude'], 44.3615);
    expect(map['locationLabel'], 'Baghdad');
    expect(map['location'], isA<Map<String, dynamic>>());
    expect((map['location'] as Map)['lat'], 33.3128);
    expect((map['location'] as Map)['lng'], 44.3615);
    expect((map['location'] as Map)['label'], 'Baghdad');
    expect(map['createdAt'], isA<Timestamp>());
    expect(map['updatedAt'], isA<Timestamp>());
  });

  test('RequestDto.fromJson accepts backend request payload shape', () {
    final dto = RequestDto.fromJson({
      'id': 'req_backend',
      'clientId': 'user1',
      'type': 'Wedding',
      'sessionDate': '2026-02-01',
      'sessionTime': '10:00',
      'governorate': 'Baghdad',
      'durationHours': 2,
      'referenceImages': ['https://example.com/ref.jpg'],
      'status': 'open',
      'offersCount': 0,
      'location': {'lat': 33.3128, 'lng': 44.3615, 'label': 'Baghdad'},
      'createdAt': '2026-01-28T10:00:00.000',
      'updatedAt': '2026-01-28T10:00:00.000',
    });

    expect(dto.date, '2026-02-01');
    expect(dto.time, '10:00');
    expect(dto.latitude, 33.3128);
    expect(dto.longitude, 44.3615);
    expect(dto.locationLabel, 'Baghdad');
  });

  test(
    'RequestDto prefers backend media routes when media ids are present',
    () {
      final dto = RequestDto.fromJson({
        'id': 'req_backend',
        'clientId': 'user1',
        'type': 'Wedding',
        'sessionDate': '2026-02-01',
        'sessionTime': '10:00',
        'governorate': 'Baghdad',
        'durationHours': 2,
        'referenceImageMediaIds': ['media-request-1'],
        'referenceImages': [
          'https://firebasestorage.googleapis.com/v0/b/legacy/o/request.jpg',
        ],
        'status': 'open',
        'offersCount': 0,
        'createdAt': '2026-01-28T10:00:00.000',
        'updatedAt': '2026-01-28T10:00:00.000',
      });

      expect(dto.referenceImageMediaIds, ['media-request-1']);
      expect(dto.referenceImages, [
        contains('/api/v1/media/media-request-1/content'),
      ]);
    },
  );

  test('RequestDto.toBackendCreateJson uses backend field names', () {
    final now = DateTime(2026, 1, 28, 10, 0);
    final dto = RequestDto(
      id: 'req1',
      clientId: 'user1',
      type: 'Wedding',
      date: '2026-02-01',
      time: '10:00',
      governorate: 'Baghdad',
      address: 'Address',
      budgetMin: 100,
      budgetMax: 200,
      durationHours: 2,
      style: 'Classic',
      deliverables: const {'photosCount': 10},
      notes: 'Notes',
      referenceImages: const [],
      status: 'draft',
      offersCount: 0,
      selectedOfferId: null,
      selectedPhotographerId: null,
      expiresAt: now.add(const Duration(days: 2)),
      createdAt: now,
      updatedAt: now,
      latitude: 33.3128,
      longitude: 44.3615,
      locationLabel: 'Baghdad',
      location: const RequestLocationDto(
        lat: 33.3128,
        lng: 44.3615,
        label: 'Baghdad',
      ),
    );

    final json = dto.toBackendCreateJson();

    expect(json['sessionDate'], '2026-02-01');
    expect(json['sessionTime'], '10:00');
    expect(json['durationHours'], 2);
    expect((json['location'] as Map<String, dynamic>)['label'], 'Baghdad');
    expect(json.containsKey('id'), isFalse);
    expect(json.containsKey('createdAt'), isFalse);
  });
}
