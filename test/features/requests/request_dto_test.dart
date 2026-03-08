import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luqta/features/requests/data/dtos/request_dto.dart';

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
}
