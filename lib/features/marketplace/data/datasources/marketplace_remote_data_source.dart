import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';

abstract class MarketplaceRemoteDataSource {
  Future<List<MarketplaceFeedEntry>> getHomeFeed({
    required int limit,
    String? city,
  });

  Future<MarketplaceExploreData> getExploreMarketplace({
    required int limit,
    String? city,
  });

  Future<MarketplacePhotographerProfile> getPhotographerProfile(
    String photographerId,
  );

  Future<List<MarketplaceVenue>> listVenues({
    String? city,
    String? type,
    String? ownerUserId,
    bool featuredOnly = false,
    int limit = 20,
    String? cursor,
  });

  Future<MarketplaceVenue> getVenueById(String venueId);

  Future<List<MarketplaceVenue>> listLocations({
    String? city,
    int limit = 20,
    String? cursor,
  });

  Future<MarketplaceVenue> getLocationById(String locationId);

  Future<List<SubscriptionPlanEntity>> listSubscriptionPlans();

  Future<UserSubscriptionEntity?> getCurrentSubscription();

  Future<UserSubscriptionEntity> subscribeToPlan({
    required String planCode,
    required int cycleMonths,
    required bool autoRenew,
  });

  Future<SponsoredCampaignEntity> createCampaign({
    required MarketplaceCampaignType type,
    required String title,
    String? description,
    required double budgetTotal,
    required double dailyBudget,
    required String currency,
    required DateTime startsAt,
    required DateTime endsAt,
    required List<Map<String, String>> targets,
  });

  Future<SponsoredCampaignEntity> submitCampaign(String campaignId);

  Future<List<SponsoredCampaignEntity>> listCampaigns({
    int limit = 20,
    String? cursor,
    MarketplaceCampaignStatus? status,
  });

  Future<SponsoredCampaignEntity> getCampaign(String campaignId);

  Future<VenueBookingEntity> createVenueBooking({
    required String venueId,
    required DateTime eventDate,
    int? guestCount,
    String? note,
    double? priceAmount,
    double? depositAmount,
    String currency = 'USD',
  });
}
