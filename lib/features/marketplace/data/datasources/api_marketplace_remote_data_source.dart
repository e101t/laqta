import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/marketplace/data/datasources/marketplace_remote_data_source.dart';
import 'package:laqta/features/marketplace/data/dtos/marketplace_dtos.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';

class ApiMarketplaceRemoteDataSource implements MarketplaceRemoteDataSource {
  ApiMarketplaceRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<List<MarketplaceFeedEntry>> getHomeFeed({
    required int limit,
    String? city,
  }) async {
    final response = await _apiClient.get(
      '/explore/feed${_buildQuery({'limit': '$limit', if (city != null && city.isNotEmpty) 'city': city})}',
      authorized: false,
    );
    final data = _readMap(response);
    final items = data['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(MarketplaceFeedEntryDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<MarketplaceExploreData> getExploreMarketplace({
    required int limit,
    String? city,
  }) async {
    final response = await _apiClient.get(
      '/explore/marketplace${_buildQuery({'limit': '$limit', if (city != null && city.isNotEmpty) 'city': city})}',
      authorized: false,
    );
    return MarketplaceExploreDto.fromJson(_readMap(response));
  }

  @override
  Future<MarketplacePhotographerProfile> getPhotographerProfile(
    String photographerId,
  ) async {
    final response = await _apiClient.get(
      '/explore/photographers/$photographerId',
      authorized: false,
    );
    return MarketplacePhotographerProfileDto.fromJson(
      _readNestedMap(response, 'profile'),
    );
  }

  @override
  Future<List<MarketplaceVenue>> listVenues({
    String? city,
    String? type,
    String? ownerUserId,
    bool featuredOnly = false,
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _apiClient.get(
      '/venues${_buildQuery({'limit': '$limit', if (city != null && city.isNotEmpty) 'city': city, if (type != null && type.isNotEmpty) 'type': type, if (ownerUserId != null && ownerUserId.isNotEmpty) 'ownerUserId': ownerUserId, if (featuredOnly) 'featuredOnly': 'true', if (cursor != null && cursor.isNotEmpty) 'cursor': cursor})}',
      authorized: false,
    );
    final data = _readMap(response);
    final venues = data['venues'] as List<dynamic>? ?? const [];
    return venues
        .whereType<Map<String, dynamic>>()
        .map(MarketplaceVenueDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<MarketplaceVenue> getVenueById(String venueId) async {
    final response = await _apiClient.get(
      '/venues/$venueId',
      authorized: false,
    );
    return MarketplaceVenueDto.fromJson(_readNestedMap(response, 'venue'));
  }

  @override
  Future<List<MarketplaceVenue>> listLocations({
    String? city,
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _apiClient.get(
      '/locations${_buildQuery({'limit': '$limit', if (city != null && city.isNotEmpty) 'city': city, if (cursor != null && cursor.isNotEmpty) 'cursor': cursor})}',
      authorized: false,
    );
    final data = _readMap(response);
    final locations = data['locations'] as List<dynamic>? ?? const [];
    return locations
        .whereType<Map<String, dynamic>>()
        .map(MarketplaceVenueDto.fromJson)
        .toList(growable: false);
  }

  @override
  Future<MarketplaceVenue> getLocationById(String locationId) async {
    final response = await _apiClient.get(
      '/locations/$locationId',
      authorized: false,
    );
    return MarketplaceVenueDto.fromJson(_readNestedMap(response, 'location'));
  }

  @override
  Future<List<SubscriptionPlanEntity>> listSubscriptionPlans() async {
    final response = await _apiClient.get(
      '/subscriptions/plans',
      authorized: false,
    );
    final plans = _readNestedList(response, 'plans');
    return plans.map(SubscriptionPlanDto.fromJson).toList(growable: false);
  }

  @override
  Future<UserSubscriptionEntity?> getCurrentSubscription() async {
    final response = await _apiClient.get('/subscriptions/me');
    final data = _readMap(response);
    final subscription = data['subscription'];
    if (subscription is Map<String, dynamic>) {
      return UserSubscriptionDto.fromJson(subscription);
    }
    if (subscription is Map) {
      return UserSubscriptionDto.fromJson(
        Map<String, dynamic>.from(subscription),
      );
    }
    return null;
  }

  @override
  Future<UserSubscriptionEntity> subscribeToPlan({
    required String planCode,
    required int cycleMonths,
    required bool autoRenew,
  }) async {
    final response = await _apiClient.post(
      '/subscriptions/subscribe',
      body: {
        'planCode': planCode,
        'cycleMonths': cycleMonths,
        'autoRenew': autoRenew,
        'paymentProvider': 'manual_pending',
      },
    );
    return UserSubscriptionDto.fromJson(
      _readNestedMap(response, 'subscription'),
    );
  }

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
  }) async {
    final response = await _apiClient.post(
      '/campaigns',
      body: {
        'type': _campaignTypeValue(type),
        'title': title,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'budgetTotal': budgetTotal,
        'dailyBudget': dailyBudget,
        'currency': currency,
        'startsAt': startsAt.toIso8601String(),
        'endsAt': endsAt.toIso8601String(),
        'targets': targets,
      },
    );
    return SponsoredCampaignDto.fromJson(_readNestedMap(response, 'campaign'));
  }

  @override
  Future<SponsoredCampaignEntity> submitCampaign(String campaignId) async {
    final response = await _apiClient.post('/campaigns/$campaignId/submit');
    return SponsoredCampaignDto.fromJson(_readNestedMap(response, 'campaign'));
  }

  @override
  Future<List<SponsoredCampaignEntity>> listCampaigns({
    int limit = 20,
    String? cursor,
    MarketplaceCampaignStatus? status,
  }) async {
    final response = await _apiClient.get(
      '/campaigns${_buildQuery({'limit': '$limit', if (cursor != null && cursor.isNotEmpty) 'cursor': cursor, if (status != null) 'status': _campaignStatusValue(status)})}',
    );
    final campaigns = _readNestedList(response, 'campaigns');
    return campaigns.map(SponsoredCampaignDto.fromJson).toList(growable: false);
  }

  @override
  Future<SponsoredCampaignEntity> getCampaign(String campaignId) async {
    final response = await _apiClient.get('/campaigns/$campaignId');
    return SponsoredCampaignDto.fromJson(_readNestedMap(response, 'campaign'));
  }

  @override
  Future<VenueBookingEntity> createVenueBooking({
    required String venueId,
    required DateTime eventDate,
    int? guestCount,
    String? note,
    double? priceAmount,
    double? depositAmount,
    String currency = 'USD',
  }) async {
    final trimmedNote = note?.trim();
    final body = <String, dynamic>{
      'eventDate': eventDate.toIso8601String(),
      'currency': currency,
    };
    if (guestCount case final value?) {
      body['guestCount'] = value;
    }
    if (trimmedNote case final value? when value.isNotEmpty) {
      body['note'] = value;
    }
    if (priceAmount case final value?) {
      body['priceAmount'] = value;
    }
    if (depositAmount case final value?) {
      body['depositAmount'] = value;
    }

    final response = await _apiClient.post(
      '/venues/$venueId/bookings',
      body: body,
    );
    return VenueBookingDto.fromJson(_readNestedMap(response, 'booking'));
  }

  String _buildQuery(Map<String, String> query) {
    if (query.isEmpty) {
      return '';
    }
    return '?${Uri(queryParameters: query).query}';
  }

  Map<String, dynamic> _readMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    throw const BackendApiException('Unexpected backend response format.');
  }

  Map<String, dynamic> _readNestedMap(dynamic response, String key) {
    final map = _readMap(response);
    final nested = map[key];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    if (nested is Map) {
      return Map<String, dynamic>.from(nested);
    }
    throw BackendApiException('Missing "$key" payload from backend.');
  }

  List<Map<String, dynamic>> _readNestedList(dynamic response, String key) {
    final map = _readMap(response);
    final nested = map[key];
    if (nested is List) {
      return nested
          .whereType<Map<Object?, Object?>>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }
    throw BackendApiException('Missing "$key" list from backend.');
  }

  String _campaignTypeValue(MarketplaceCampaignType type) {
    switch (type) {
      case MarketplaceCampaignType.promoteProfile:
        return 'promote_profile';
      case MarketplaceCampaignType.promoteReel:
        return 'promote_reel';
      case MarketplaceCampaignType.promoteStory:
        return 'promote_story';
      case MarketplaceCampaignType.promoteVenue:
        return 'promote_venue';
    }
  }

  String _campaignStatusValue(MarketplaceCampaignStatus status) {
    switch (status) {
      case MarketplaceCampaignStatus.draft:
        return 'draft';
      case MarketplaceCampaignStatus.pendingReview:
        return 'pending_review';
      case MarketplaceCampaignStatus.approved:
        return 'approved';
      case MarketplaceCampaignStatus.rejected:
        return 'rejected';
      case MarketplaceCampaignStatus.active:
        return 'active';
      case MarketplaceCampaignStatus.paused:
        return 'paused';
      case MarketplaceCampaignStatus.completed:
        return 'completed';
    }
  }
}
