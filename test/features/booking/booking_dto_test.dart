import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/booking/data/dtos/booking_dto.dart';

void main() {
  group('BookingDto', () {
    test(
      'nested value objects preserve booking payment location and timeline',
      () {
        final paidAt = DateTime.utc(2026, 6, 1, 10);
        final confirmedAt = DateTime.utc(2026, 6, 1, 11);
        final deliveredAt = DateTime.utc(2026, 6, 2, 12);

        final payment = BookingPaymentDto(
          status: 'paid',
          intentId: 'pi_123',
          amount: 150,
          paidAt: paidAt,
        );
        final location = BookingLocationDto(
          lat: 33.31,
          lng: 44.36,
          text: 'Baghdad',
        );
        final deliverables = BookingDeliverablesDto(
          photosCount: 50,
          videoMinutes: 5,
          includesEditing: true,
          includesVideo: true,
          notes: 'Same day preview',
        );
        final timeline = BookingTimelineDto(
          confirmedAt: confirmedAt,
          deliveredAt: deliveredAt,
        );

        expect(payment.toMap()['status'], 'paid');
        expect(payment.toMap()['intentId'], 'pi_123');
        expect(location.toMap(), {
          'lat': 33.31,
          'lng': 44.36,
          'text': 'Baghdad',
        });
        expect(deliverables.toMap()['includesEditing'], isTrue);
        expect(deliverables.toMap()['includesVideo'], isTrue);
        expect(timeline.toMap()['confirmedAt'], isNotNull);
        expect(timeline.toMap()['deliveredAt'], isNotNull);
      },
    );

    test('toJson exposes backend-friendly booking shape', () {
      final createdAt = DateTime.utc(2026, 6, 1);
      final updatedAt = DateTime.utc(2026, 6, 2);
      final booking = BookingDto(
        id: 'b1',
        customerId: 'customer1',
        photographerId: 'photographer1',
        requestId: 'request1',
        offerId: 'offer1',
        date: '2026-06-20',
        time: '14:30',
        duration: 120,
        type: 'wedding',
        price: 250,
        currency: 'USD',
        status: 'confirmed',
        payment: const BookingPaymentDto(status: 'pending'),
        location: const BookingLocationDto(text: 'Baghdad'),
        deliverables: const BookingDeliverablesDto(photosCount: 30),
        notes: 'Outdoor shoot',
        chatId: 'chat1',
        deliveryId: 'delivery1',
        disputeId: 'dispute1',
        revisionCount: 1,
        canceledBy: null,
        timeline: const BookingTimelineDto(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final json = booking.toJson();

      expect(json['id'], 'b1');
      expect(json['customerId'], 'customer1');
      expect(json['photographerId'], 'photographer1');
      expect(json['requestId'], 'request1');
      expect(json['duration'], 120);
      expect(json['price'], 250);
      expect(json['payment'], isA<Map<String, dynamic>>());
      expect(json['location'], isA<Map<String, dynamic>>());
      expect(json['deliverables'], isA<Map<String, dynamic>>());
      expect(json['createdAt'], createdAt.toIso8601String());
      expect(json['updatedAt'], updatedAt.toIso8601String());
    });

    test(
      'fromMap helpers use safe defaults for optional nested structures',
      () {
        final payment = BookingPaymentDto.fromMap({
          'status': 'paid',
          'amount': '99.5',
        });
        final location = BookingLocationDto.fromMap({
          'lat': '33.3',
          'lng': 44,
          'text': 'Baghdad',
        });
        final deliverables = BookingDeliverablesDto.fromMap({
          'photosCount': '10',
          'videoMinutes': 3.7,
          'includesEditing': true,
          'includesVideo': false,
        });
        final timeline = BookingTimelineDto.fromMap(const {});

        expect(payment.status, 'paid');
        expect(payment.amount, 99.5);
        expect(location.lat, 33.3);
        expect(location.lng, 44);
        expect(deliverables.photosCount, 10);
        expect(deliverables.videoMinutes, 3);
        expect(deliverables.includesEditing, isTrue);
        expect(timeline.confirmedAt, isNull);
        expect(timeline.canceledAt, isNull);
      },
    );
  });
}
