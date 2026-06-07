import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';
import 'package:laqta/features/marketplace/domain/repositories/marketplace_repository.dart';

class MarketplaceTargetOption {
  final String entityId;
  final String label;
  final String targetType;
  final String? imageUrl;

  const MarketplaceTargetOption({
    required this.entityId,
    required this.label,
    required this.targetType,
    this.imageUrl,
  });
}

abstract class MarketplaceController extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  @protected
  void setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  @protected
  void setError(String? value) {
    _error = value;
    notifyListeners();
  }

  @protected
  Future<T?> guard<T>(Future<T> Function() action) async {
    try {
      setError(null);
      return await action();
    } on BackendApiException catch (error) {
      setError(error.message);
    } catch (error) {
      setError(error.toString());
    }
    return null;
  }
}

class HomeFeedController extends MarketplaceController {
  HomeFeedController(this._repository);

  final MarketplaceRepository _repository;

  List<MarketplaceFeedEntry> items = const [];
  String? city;

  Future<void> load() async {
    setLoading(true);
    final result = await guard(
      () => _repository.getHomeFeed(limit: 15, city: city),
    );
    if (result != null) {
      items = result;
    }
    setLoading(false);
  }
}

class ExploreMarketplaceController extends MarketplaceController {
  ExploreMarketplaceController(this._repository);

  final MarketplaceRepository _repository;

  MarketplaceExploreData? data;
  String? city;

  Future<void> load() async {
    setLoading(true);
    final result = await guard(
      () => _repository.getExploreMarketplace(limit: 12, city: city),
    );
    if (result != null) {
      data = result;
    }
    setLoading(false);
  }
}

class PhotographerProfileController extends MarketplaceController {
  PhotographerProfileController(this._repository, this.photographerId);

  final MarketplaceRepository _repository;
  final String photographerId;

  MarketplacePhotographerProfile? profile;

  Future<void> load() async {
    setLoading(true);
    final result = await guard(
      () => _repository.getPhotographerProfile(photographerId),
    );
    if (result != null) {
      profile = result;
    }
    setLoading(false);
  }
}

class VenueCatalogueController extends MarketplaceController {
  VenueCatalogueController(this._repository, {this.onlyLocations = false});

  final MarketplaceRepository _repository;
  final bool onlyLocations;

  List<MarketplaceVenue> items = const [];
  String selectedCity = 'الكل';
  String? nextCursor;

  List<String> get cities {
    final values =
        items
            .map((item) => item.city.trim())
            .where((item) => item.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    return ['الكل', ...values];
  }

  List<MarketplaceVenue> get filteredItems {
    if (selectedCity == 'الكل') {
      return items;
    }
    return items
        .where((item) => item.city == selectedCity)
        .toList(growable: false);
  }

  Future<void> load() async {
    setLoading(true);
    final result = await guard(
      () => onlyLocations
          ? _repository.listLocations(limit: 24)
          : _repository.listVenues(limit: 24),
    );
    if (result != null) {
      items = result;
    }
    setLoading(false);
  }

  void setCity(String city) {
    selectedCity = city;
    notifyListeners();
  }
}

class VenueDetailsController extends MarketplaceController {
  VenueDetailsController(
    this._repository,
    this.venueId, {
    this.isLocation = false,
  });

  final MarketplaceRepository _repository;
  final String venueId;
  final bool isLocation;

  MarketplaceVenue? venue;
  VenueBookingEntity? lastBooking;
  bool isSubmittingBooking = false;

  Future<void> load() async {
    setLoading(true);
    final result = await guard(
      () => isLocation
          ? _repository.getLocationById(venueId)
          : _repository.getVenueById(venueId),
    );
    if (result != null) {
      venue = result;
    }
    setLoading(false);
  }

  Future<bool> submitBooking({
    required DateTime eventDate,
    int? guestCount,
    String? note,
    double? priceAmount,
    double? depositAmount,
  }) async {
    isSubmittingBooking = true;
    notifyListeners();
    final result = await guard(
      () => _repository.createVenueBooking(
        venueId: venueId,
        eventDate: eventDate,
        guestCount: guestCount,
        note: note,
        priceAmount: priceAmount,
        depositAmount: depositAmount,
      ),
    );
    isSubmittingBooking = false;
    if (result != null) {
      lastBooking = result;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}

class SubscriptionPlansController extends MarketplaceController {
  SubscriptionPlansController(this._repository);

  final MarketplaceRepository _repository;

  List<SubscriptionPlanEntity> plans = const [];
  UserSubscriptionEntity? currentSubscription;
  bool yearly = false;
  bool isSubscribing = false;

  Future<void> load() async {
    setLoading(true);
    final results = await Future.wait([
      guard(() => _repository.listSubscriptionPlans()),
      guard(() => _repository.getCurrentSubscription()),
    ]);

    final loadedPlans = results[0] as List<SubscriptionPlanEntity>?;
    final loadedSubscription = results[1] as UserSubscriptionEntity?;

    if (loadedPlans != null) {
      plans = loadedPlans;
    }
    currentSubscription = loadedSubscription;
    setLoading(false);
  }

  void setYearly(bool value) {
    yearly = value;
    notifyListeners();
  }

  Future<bool> subscribe(String planCode) async {
    isSubscribing = true;
    notifyListeners();
    final result = await guard(
      () => _repository.subscribeToPlan(
        planCode: planCode,
        cycleMonths: yearly ? 12 : 1,
        autoRenew: yearly,
      ),
    );
    isSubscribing = false;
    if (result != null) {
      currentSubscription = result;
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }
}

class SponsoredAdController extends MarketplaceController {
  SponsoredAdController(this._repository, this._currentUserId);

  final MarketplaceRepository _repository;
  final String? _currentUserId;

  MarketplaceCampaignType selectedType = MarketplaceCampaignType.promoteProfile;
  int selectedDurationDays = 7;
  String selectedRegion = 'بغداد';
  int budget = 15;
  MarketplacePhotographerProfile? currentProfile;
  List<MarketplaceVenue> ownedVenues = const [];
  List<SponsoredCampaignEntity> recentCampaigns = const [];
  MarketplaceTargetOption? selectedTarget;
  bool isSubmitting = false;

  List<MarketplaceTargetOption> get targetOptions {
    final profile = currentProfile;
    switch (selectedType) {
      case MarketplaceCampaignType.promoteProfile:
        final currentUserId = _currentUserId;
        if (currentUserId == null || profile == null) {
          return const [];
        }
        return [
          MarketplaceTargetOption(
            entityId: currentUserId,
            label: profile.name,
            targetType: 'profile',
            imageUrl: profile.photoUrl,
          ),
        ];
      case MarketplaceCampaignType.promoteReel:
        if (profile == null) {
          return const [];
        }
        return profile.reels
            .map(
              (reel) => MarketplaceTargetOption(
                entityId: reel.id,
                label: reel.caption ?? 'ريل ${reel.id.substring(0, 6)}',
                targetType: 'reel',
                imageUrl: reel.mediaUrl,
              ),
            )
            .toList(growable: false);
      case MarketplaceCampaignType.promoteStory:
        if (profile == null) {
          return const [];
        }
        return profile.stories
            .map(
              (story) => MarketplaceTargetOption(
                entityId: story.id,
                label: story.caption ?? 'ستوري ${story.id.substring(0, 6)}',
                targetType: 'story',
                imageUrl: story.mediaUrl,
              ),
            )
            .toList(growable: false);
      case MarketplaceCampaignType.promoteVenue:
        return ownedVenues
            .map(
              (venue) => MarketplaceTargetOption(
                entityId: venue.id,
                label: venue.name,
                targetType: 'venue',
                imageUrl: venue.coverUrl,
              ),
            )
            .toList(growable: false);
    }
  }

  Future<void> load() async {
    setLoading(true);
    final currentUserId = _currentUserId;
    if (currentUserId == null || currentUserId.isEmpty) {
      setError('تعذر تحديد المستخدم الحالي.');
      setLoading(false);
      return;
    }

    final profileResult = await guard(
      () => _repository.getPhotographerProfile(currentUserId),
    );
    final venueResult = await guard(
      () => _repository.listVenues(ownerUserId: currentUserId, limit: 24),
    );
    final campaignsResult = await guard(
      () => _repository.listCampaigns(limit: 20),
    );

    if (profileResult != null) {
      currentProfile = profileResult;
    }
    if (venueResult != null) {
      ownedVenues = venueResult;
    }
    if (campaignsResult != null) {
      recentCampaigns = campaignsResult;
    }

    final options = targetOptions;
    if (options.isNotEmpty) {
      selectedTarget = options.first;
    }
    setLoading(false);
  }

  void selectType(MarketplaceCampaignType type) {
    selectedType = type;
    final options = targetOptions;
    selectedTarget = options.isEmpty ? null : options.first;
    notifyListeners();
  }

  void selectDuration(int days) {
    selectedDurationDays = days;
    notifyListeners();
  }

  void selectRegion(String region) {
    selectedRegion = region;
    notifyListeners();
  }

  void setBudget(int value) {
    budget = value.clamp(5, 500);
    notifyListeners();
  }

  void selectTarget(MarketplaceTargetOption? value) {
    selectedTarget = value;
    notifyListeners();
  }

  Future<SponsoredCampaignEntity?> createAndSubmit() async {
    final target = selectedTarget;
    if (target == null) {
      setError('اختر العنصر الذي تريد ترويجه أولًا.');
      return null;
    }

    isSubmitting = true;
    notifyListeners();

    final now = DateTime.now();
    final campaign = await guard(
      () => _repository.createCampaign(
        type: selectedType,
        title: _campaignTitle(),
        description: 'حملة ممولة من تطبيق LAQTA',
        budgetTotal: budget.toDouble(),
        dailyBudget: (budget / selectedDurationDays)
            .clamp(1, budget)
            .toDouble(),
        currency: 'USD',
        startsAt: now,
        endsAt: now.add(Duration(days: selectedDurationDays)),
        targets: [
          {'targetType': target.targetType, 'entityId': target.entityId},
        ],
      ),
    );

    if (campaign == null) {
      isSubmitting = false;
      notifyListeners();
      return null;
    }

    final submitted = await guard(
      () => _repository.submitCampaign(campaign.id),
    );
    isSubmitting = false;

    if (submitted != null) {
      recentCampaigns = [
        submitted,
        ...recentCampaigns.where((item) => item.id != submitted.id),
      ];
      notifyListeners();
      return submitted;
    }

    notifyListeners();
    return campaign;
  }

  String _campaignTitle() {
    switch (selectedType) {
      case MarketplaceCampaignType.promoteProfile:
        return 'ترويج الحساب';
      case MarketplaceCampaignType.promoteReel:
        return 'ترويج ريل';
      case MarketplaceCampaignType.promoteStory:
        return 'ترويج ستوري';
      case MarketplaceCampaignType.promoteVenue:
        return 'ترويج مكان/قاعة';
    }
  }
}

class CampaignAnalyticsController extends MarketplaceController {
  CampaignAnalyticsController(this._repository, this.campaignId);

  final MarketplaceRepository _repository;
  final String campaignId;

  SponsoredCampaignEntity? campaign;

  Future<void> load() async {
    setLoading(true);
    final result = await guard(() => _repository.getCampaign(campaignId));
    if (result != null) {
      campaign = result;
    }
    setLoading(false);
  }
}
