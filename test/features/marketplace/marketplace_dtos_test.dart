import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/marketplace/data/dtos/marketplace_dtos.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';

void main() {
  group('Marketplace DTOs', () {
    test('photographer summary trims strings and coerces numeric fields', () {
      final photographer = MarketplacePhotographerSummaryDto.fromJson({
        'id': 'p1',
        'name': ' Sara ',
        'photoUrl': ' https://cdn.example/p1.jpg ',
        'governorate': 'Baghdad',
        'bio': ' Wedding photographer ',
        'specialties': ['wedding', ' ', 42, 'events'],
        'basePrice': '150.5',
        'verified': true,
        'ratingAverage': 4,
        'ratingCount': '12',
        'rankingScore': '88.75',
      });

      expect(photographer.id, 'p1');
      expect(photographer.name, ' Sara ');
      expect(photographer.photoUrl, 'https://cdn.example/p1.jpg');
      expect(photographer.specialties, ['wedding', 'events']);
      expect(photographer.basePrice, 150.5);
      expect(photographer.verified, isTrue);
      expect(photographer.ratingAverage, 4);
      expect(photographer.ratingCount, 12);
      expect(photographer.rankingScore, 88.75);
    });

    test(
      'venue maps nested media reviews availability and category safely',
      () {
        final venue = MarketplaceVenueDto.fromJson({
          'id': 'v1',
          'ownerUserId': 'owner1',
          'type': 'garden',
          'name': 'Venue',
          'slug': 'venue',
          'city': 'Baghdad',
          'area': ' Karrada ',
          'services': ['photo', null, 'video'],
          'latitude': '33.31',
          'longitude': 44.36,
          'capacityMin': '50',
          'capacityMax': 300,
          'pricingFrom': '1000',
          'pricingTo': 2000,
          'isFeatured': true,
          'featuredUntil': '2026-07-01T00:00:00.000Z',
          'ratingAverage': '4.6',
          'reviewCount': '9',
          'category': {'name': 'Halls', 'slug': 'halls'},
          'media': [
            {
              'id': 'm1',
              'mediaId': 'media1',
              'role': 'cover',
              'caption': ' Main ',
              'sortOrder': '2',
              'url': 'https://cdn.example/v1.jpg',
            },
          ],
          'reviews': [
            {
              'id': 'r1',
              'userId': 'u1',
              'rating': '5',
              'title': 'Great',
              'comment': 'Nice',
              'createdAt': '2026-06-01T00:00:00.000Z',
            },
          ],
          'availability': [
            {
              'id': 'a1',
              'date': '2026-06-15T00:00:00.000Z',
              'status': 'blocked',
              'startTime': '10:00',
              'endTime': '12:00',
            },
          ],
          'createdAt': '2026-01-01T00:00:00.000Z',
          'updatedAt': '2026-01-02T00:00:00.000Z',
          'rankingScore': '7.5',
        });

        expect(venue.isLocationType, isTrue);
        expect(venue.area, 'Karrada');
        expect(venue.services, ['photo', 'video']);
        expect(venue.latitude, 33.31);
        expect(venue.capacityMin, 50);
        expect(venue.pricingFrom, 1000);
        expect(venue.categoryName, 'Halls');
        expect(venue.media.single.sortOrder, 2);
        expect(venue.reviews.single.rating, 5);
        expect(venue.availability.single.status, 'blocked');
        expect(venue.rankingScore, 7.5);
      },
    );

    test('feed entry selects the expected payload by kind', () {
      final reelEntry = MarketplaceFeedEntryDto.fromJson({
        'kind': 'reel',
        'rankingScore': '10',
        'isSponsored': true,
        'payload': {
          'id': 'reel1',
          'mediaId': 'media1',
          'mediaUrl': 'https://cdn.example/reel.mp4',
          'likes': '4',
          'comments': 2,
          'shares': '1',
          'views': '100',
          'createdAt': '2026-06-01T00:00:00.000Z',
        },
      });

      final photographerEntry = MarketplaceFeedEntryDto.fromJson({
        'kind': 'photographer',
        'payload': {'id': 'p2', 'name': 'Ali'},
      });

      expect(reelEntry.kind, MarketplaceFeedKind.reel);
      expect(reelEntry.reel?.views, 100);
      expect(reelEntry.isSponsored, isTrue);
      expect(photographerEntry.kind, MarketplaceFeedKind.photographer);
      expect(photographerEntry.photographer?.name, 'Ali');
      expect(photographerEntry.reel, isNull);
    });

    test('subscription and sponsored campaign DTOs map defaults and enums', () {
      final planJson = {
        'id': 'plan1',
        'code': 'pro',
        'name': 'Pro',
        'reelsLimit': '10',
        'storiesLimit': 20,
        'portfolioLimit': '6',
        'featuredEnabled': true,
        'analyticsEnabled': true,
        'sponsoredDiscountPercent': '15',
        'priorityRankWeight': '1.5',
        'features': {'support': true, 'badge': 'yes'},
      };

      final plan = SubscriptionPlanDto.fromJson(planJson);
      final subscription = UserSubscriptionDto.fromJson({
        'id': 'sub1',
        'userId': 'u1',
        'status': 'active',
        'startsAt': '2026-06-01T00:00:00.000Z',
        'endsAt': '2026-07-01T00:00:00.000Z',
        'autoRenew': true,
        'usage': {
          'reelsUsed': '1',
          'storiesUsed': 2,
          'portfolioUsed': '3',
          'featuredUsed': 4,
        },
        'plan': planJson,
      });

      final campaign = SponsoredCampaignDto.fromJson({
        'id': 'c1',
        'ownerUserId': 'u1',
        'type': 'promote_reel',
        'title': 'Campaign',
        'status': 'approved',
        'budgetTotal': '100',
        'dailyBudget': 10,
        'spentAmount': '2.5',
        'startsAt': '2026-06-01T00:00:00.000Z',
        'endsAt': '2026-06-10T00:00:00.000Z',
        'targets': [
          {'id': 't1', 'targetType': 'reel', 'entityId': 'reel1'},
        ],
        'analytics': {
          'impressions': '1000',
          'clicks': '50',
          'ctr': '5',
          'spendAmount': '2.5',
        },
        'payments': [
          {
            'id': 'pay1',
            'amount': '20',
            'currency': 'USD',
            'status': 'paid',
            'provider': 'stripe',
            'providerRef': 'pi_test',
            'paidAt': '2026-06-02T00:00:00.000Z',
          },
        ],
        'createdAt': '2026-06-01T00:00:00.000Z',
        'updatedAt': '2026-06-02T00:00:00.000Z',
      });

      expect(plan.reelsLimit, 10);
      expect(plan.priorityRankWeight, 1.5);
      expect(plan.features, {'support': 'true', 'badge': 'yes'});
      expect(subscription.reelsUsed, 1);
      expect(subscription.autoRenew, isTrue);
      expect(campaign.type, MarketplaceCampaignType.promoteReel);
      expect(campaign.status, MarketplaceCampaignStatus.approved);
      expect(campaign.analytics.impressions, 1000);
      expect(campaign.payments.single.amount, 20);
    });
  });
}
