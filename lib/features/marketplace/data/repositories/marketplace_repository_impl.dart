import 'package:laqta/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  MarketplaceRepositoryImpl(this._remoteDataSource);

  final MarketplaceRemoteDataSource _remoteDataSource;

  @override
  Future<List<MarketplaceFeedEntry>> getHomeFeed({
    required int limit,
    String? city,
  }) => _remoteDataSource.getHomeFeed(limit: limit, city: city);

  @override
  Future<MarketplaceExploreData> getExploreMarketplace({
    required int limit,
    String? city,
  }) => _remoteDataSource.getExploreMarketplace(limit: limit, city: city);

  @override
  Future<MarketplacePhotographerProfile> getPhotographerProfile(
    String photographerId,
  ) => _remoteDataSource.getPhotographerProfile(photographerId);

  @override
  Future<List<MarketplaceVenue>> listVenues({
    String? city,
    String? type,
    String? ownerUserId,
    bool featuredOnly = false,
    int limit = 20,
    String? cursor,
  }) => _remoteDataSource.listVenues(
    city: city,
    type: type,
    ownerUserId: ownerUserId,
    featuredOnly: featuredOnly,
    limit: limit,
    cursor: cursor,
  );

  @override
  Future<MarketplaceVenue> getVenueById(String venueId) =>
      _remoteDataSource.getVenueById(venueId);

  @override
  Future<List<MarketplaceVenue>> listLocations({
    String? city,
    int limit = 20,
    String? cursor,
  }) =>
      _remoteDataSource.listLocations(city: city, limit: limit, cursor: cursor);

  @override
  Future<MarketplaceVenue> getLocationById(String locationId) =>
      _remoteDataSource.getLocationById(locationId);

  @override
  Future<List<SubscriptionPlanEntity>> listSubscriptionPlans() =>
      _remoteDataSource.listSubscriptionPlans();

  @override
  Future<UserSubscriptionEntity?> getCurrentSubscription() =>
      _remoteDataSource.getCurrentSubscription();

  @override
  Future<UserSubscriptionEntity> subscribeToPlan({
    required String planCode,
    required int cycleMonths,
    required bool autoRenew,
  }) => _remoteDataSource.subscribeToPlan(
    planCode: planCode,
    cycleMonths: cycleMonths,
    autoRenew: autoRenew,
  );

  @override
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
  }) => _remoteDataSource.createCampaign(
    type: type,
    title: title,
    description: description,
    budgetTotal: budgetTotal,
    dailyBudget: dailyBudget,
    currency: currency,
    startsAt: startsAt,
    endsAt: endsAt,
    targets: targets,
  );

  @override
  Future<SponsoredCampaignEntity> submitCampaign(String campaignId) =>
      _remoteDataSource.submitCampaign(campaignId);

  @override
  Future<List<SponsoredCampaignEntity>> listCampaigns({
    int limit = 20,
    String? cursor,
    MarketplaceCampaignStatus? status,
  }) => _remoteDataSource.listCampaigns(
    limit: limit,
    cursor: cursor,
    status: status,
  );

  @override
  Future<SponsoredCampaignEntity> getCampaign(String campaignId) =>
      _remoteDataSource.getCampaign(campaignId);

  @override
  Future<VenueBookingEntity> createVenueBooking({
    required String venueId,
    required DateTime eventDate,
    int? guestCount,
    String? note,
    double? priceAmount,
    double? depositAmount,
    String currency = 'USD',
  }) => _remoteDataSource.createVenueBooking(
    venueId: venueId,
    eventDate: eventDate,
    guestCount: guestCount,
    note: note,
    priceAmount: priceAmount,
    depositAmount: depositAmount,
    currency: currency,
  );
}
