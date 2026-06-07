import 'package:laqta/features/marketplace/domain/entities/marketplace_models.dart';

DateTime? _readDate(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

double? _readDouble(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String && value.isNotEmpty) {
    return double.tryParse(value);
  }
  return null;
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String && value.isNotEmpty) {
    return int.tryParse(value) ?? fallback;
  }
  return fallback;
}

String? _readString(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

List<String> _readStringList(dynamic value) {
  if (value is List) {
    return value.map(_readString).whereType<String>().toList(growable: false);
  }
  return const [];
}

Map<String, String> _readStringMap(dynamic value) {
  if (value is Map) {
    return value.map(
      (key, item) => MapEntry(key.toString(), item?.toString() ?? ''),
    );
  }
  return const {};
}

MarketplaceCampaignType _readCampaignType(String value) {
  switch (value) {
    case 'promote_reel':
      return MarketplaceCampaignType.promoteReel;
    case 'promote_story':
      return MarketplaceCampaignType.promoteStory;
    case 'promote_venue':
      return MarketplaceCampaignType.promoteVenue;
    case 'promote_profile':
    default:
      return MarketplaceCampaignType.promoteProfile;
  }
}

MarketplaceCampaignStatus _readCampaignStatus(String value) {
  switch (value) {
    case 'pending_review':
      return MarketplaceCampaignStatus.pendingReview;
    case 'approved':
      return MarketplaceCampaignStatus.approved;
    case 'rejected':
      return MarketplaceCampaignStatus.rejected;
    case 'active':
      return MarketplaceCampaignStatus.active;
    case 'paused':
      return MarketplaceCampaignStatus.paused;
    case 'completed':
      return MarketplaceCampaignStatus.completed;
    case 'draft':
    default:
      return MarketplaceCampaignStatus.draft;
  }
}

MarketplaceFeedKind _readFeedKind(String value) {
  switch (value) {
    case 'photographer':
      return MarketplaceFeedKind.photographer;
    case 'venue':
      return MarketplaceFeedKind.venue;
    case 'location':
      return MarketplaceFeedKind.location;
    case 'reel':
    default:
      return MarketplaceFeedKind.reel;
  }
}

class MarketplacePhotographerSummaryDto {
  MarketplacePhotographerSummaryDto._();

  static MarketplacePhotographerSummary fromJson(Map<String, dynamic> json) {
    return MarketplacePhotographerSummary(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'مصوّر',
      photoUrl: _readString(json['photoUrl']),
      governorate: _readString(json['governorate']),
      bio: _readString(json['bio']),
      specialties: _readStringList(json['specialties']),
      basePrice: _readDouble(json['basePrice']),
      verified: json['verified'] == true,
      ratingAverage: _readDouble(json['ratingAverage']),
      ratingCount: _readInt(json['ratingCount']),
      rankingScore: _readDouble(json['rankingScore']) ?? 0,
    );
  }
}

class MarketplaceReelSummaryDto {
  MarketplaceReelSummaryDto._();

  static MarketplaceReelSummary fromJson(Map<String, dynamic> json) {
    return MarketplaceReelSummary(
      id: json['id'] as String,
      photographerId: json['photographerId'] as String? ?? '',
      photographerName: json['photographerName'] as String? ?? 'مستخدم',
      photographerPhotoUrl: _readString(json['photographerPhotoUrl']),
      mediaId: json['mediaId'] as String? ?? '',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      caption: _readString(json['caption']),
      likes: _readInt(json['likes']),
      comments: _readInt(json['comments']),
      shares: _readInt(json['shares']),
      views: _readInt(json['views']),
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
      rankingScore: _readDouble(json['rankingScore']) ?? 0,
      isFeatured: json['isFeatured'] == true,
      isSponsored: json['isSponsored'] == true,
    );
  }
}

class MarketplaceVenueDto {
  MarketplaceVenueDto._();

  static MarketplaceVenue fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return MarketplaceVenue(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      type: json['type'] as String? ?? 'venue',
      name: json['name'] as String? ?? 'مكان',
      slug: json['slug'] as String? ?? '',
      city: json['city'] as String? ?? '',
      area: _readString(json['area']),
      address: _readString(json['address']),
      description: _readString(json['description']),
      services: _readStringList(json['services']),
      contactPhone: _readString(json['contactPhone']),
      contactWhatsapp: _readString(json['contactWhatsapp']),
      contactEmail: _readString(json['contactEmail']),
      latitude: _readDouble(json['latitude']),
      longitude: _readDouble(json['longitude']),
      capacityMin: json['capacityMin'] == null
          ? null
          : _readInt(json['capacityMin']),
      capacityMax: json['capacityMax'] == null
          ? null
          : _readInt(json['capacityMax']),
      pricingFrom: _readDouble(json['pricingFrom']),
      pricingTo: _readDouble(json['pricingTo']),
      pricingCurrency: json['pricingCurrency'] as String? ?? 'USD',
      isFeatured: json['isFeatured'] == true,
      featuredUntil: _readDate(json['featuredUntil']),
      verificationStatus: json['verificationStatus'] as String? ?? 'pending',
      ratingAverage: _readDouble(json['ratingAverage']),
      reviewCount: _readInt(json['reviewCount']),
      coverMediaId: _readString(json['coverMediaId']),
      coverUrl: _readString(json['coverUrl']),
      categoryName: category is Map<String, dynamic>
          ? _readString(category['name'])
          : null,
      categorySlug: category is Map<String, dynamic>
          ? _readString(category['slug'])
          : null,
      media: (json['media'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MarketplaceVenueMedia(
              id: item['id'] as String? ?? '',
              mediaId: item['mediaId'] as String? ?? '',
              role: item['role'] as String? ?? 'gallery',
              caption: _readString(item['caption']),
              sortOrder: _readInt(item['sortOrder']),
              url: item['url'] as String? ?? '',
            ),
          )
          .toList(growable: false),
      reviews: (json['reviews'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MarketplaceVenueReview(
              id: item['id'] as String? ?? '',
              userId: item['userId'] as String? ?? '',
              rating: _readInt(item['rating']),
              title: _readString(item['title']),
              comment: _readString(item['comment']),
              createdAt: _readDate(item['createdAt']) ?? DateTime.now(),
            ),
          )
          .toList(growable: false),
      availability: (json['availability'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MarketplaceVenueAvailability(
              id: item['id'] as String? ?? '',
              date: _readDate(item['date']) ?? DateTime.now(),
              status: item['status'] as String? ?? 'available',
              startTime: _readString(item['startTime']),
              endTime: _readString(item['endTime']),
              note: _readString(item['note']),
            ),
          )
          .toList(growable: false),
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(json['updatedAt']) ?? DateTime.now(),
      rankingScore: _readDouble(json['rankingScore']),
    );
  }
}

class MarketplaceFeedEntryDto {
  MarketplaceFeedEntryDto._();

  static MarketplaceFeedEntry fromJson(Map<String, dynamic> json) {
    final kind = _readFeedKind(json['kind'] as String? ?? 'reel');
    final payload = json['payload'] as Map<String, dynamic>? ?? const {};

    return MarketplaceFeedEntry(
      id:
          payload['id'] as String? ??
          json['id'] as String? ??
          UniqueId.fallback(kind.name),
      kind: kind,
      rankingScore: _readDouble(json['rankingScore']) ?? 0,
      isSponsored: json['isSponsored'] == true,
      isFeatured: json['isFeatured'] == true,
      reel: kind == MarketplaceFeedKind.reel
          ? MarketplaceReelSummaryDto.fromJson(payload)
          : null,
      photographer: kind == MarketplaceFeedKind.photographer
          ? MarketplacePhotographerSummaryDto.fromJson(payload)
          : null,
      venue:
          kind == MarketplaceFeedKind.venue ||
              kind == MarketplaceFeedKind.location
          ? MarketplaceVenueDto.fromJson(payload)
          : null,
    );
  }
}

class MarketplaceExploreDto {
  MarketplaceExploreDto._();

  static MarketplaceExploreData fromJson(Map<String, dynamic> json) {
    return MarketplaceExploreData(
      trendingPhotographers:
          (json['trendingPhotographers'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(MarketplacePhotographerSummaryDto.fromJson)
              .toList(growable: false),
      featuredVenues: (json['featuredVenues'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceVenueDto.fromJson)
          .toList(growable: false),
      nearbyPlaces: (json['nearbyPlaces'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceVenueDto.fromJson)
          .toList(growable: false),
      trendingReels: (json['trendingReels'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceReelSummaryDto.fromJson)
          .toList(growable: false),
      recommendedCreators:
          (json['recommendedCreators'] as List<dynamic>? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(MarketplacePhotographerSummaryDto.fromJson)
              .toList(growable: false),
    );
  }
}

class MarketplacePhotographerProfileDto {
  MarketplacePhotographerProfileDto._();

  static MarketplacePhotographerProfile fromJson(Map<String, dynamic> json) {
    return MarketplacePhotographerProfile(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'مصوّر',
      photoUrl: _readString(json['photoUrl']),
      governorate: _readString(json['governorate']),
      bio: _readString(json['bio']),
      specialties: _readStringList(json['specialties']),
      equipment: _readStringList(json['equipment']),
      coverageAreas: _readStringList(json['coverageAreas']),
      basePrice: _readDouble(json['basePrice']),
      verified: json['verified'] == true,
      instagramHandle: _readString(json['instagramHandle']),
      ratingAverage: _readDouble(json['ratingAverage']),
      ratingCount: _readInt(json['ratingCount']),
      projectsCount: _readInt(json['projectsCount']),
      followersCount: _readInt(json['followersCount']),
      followingCount: _readInt(json['followingCount']),
      portfolio: (json['portfolio'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MarketplaceMediaAsset(
              id: item['id'] as String? ?? '',
              mediaId: item['mediaId'] as String? ?? '',
              url: item['url'] as String? ?? '',
              mimeType: item['mimeType'] as String? ?? 'image/jpeg',
              createdAt: _readDate(item['createdAt']) ?? DateTime.now(),
            ),
          )
          .toList(growable: false),
      reels: (json['reels'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(MarketplaceReelSummaryDto.fromJson)
          .toList(growable: false),
      stories: (json['stories'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => MarketplaceStoryAsset(
              id: item['id'] as String? ?? '',
              mediaId: item['mediaId'] as String? ?? '',
              mediaUrl: item['mediaUrl'] as String? ?? '',
              caption: _readString(item['caption']),
              createdAt: _readDate(item['createdAt']) ?? DateTime.now(),
              expiresAt: _readDate(item['expiresAt']) ?? DateTime.now(),
            ),
          )
          .toList(growable: false),
      rankingScore: _readDouble(json['rankingScore']) ?? 0,
    );
  }
}

class SubscriptionPlanDto {
  SubscriptionPlanDto._();

  static SubscriptionPlanEntity fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanEntity(
      id: json['id'] as String,
      code: json['code'] as String? ?? 'basic',
      name: json['name'] as String? ?? 'Plan',
      description: _readString(json['description']),
      reelsLimit: _readInt(json['reelsLimit']),
      storiesLimit: _readInt(json['storiesLimit']),
      portfolioLimit: _readInt(json['portfolioLimit']),
      featuredEnabled: json['featuredEnabled'] == true,
      analyticsEnabled: json['analyticsEnabled'] == true,
      sponsoredDiscountPercent: _readInt(json['sponsoredDiscountPercent']),
      priorityRankWeight: _readDouble(json['priorityRankWeight']) ?? 1,
      isActive: json['isActive'] != false,
      sortOrder: _readInt(json['sortOrder']),
      features: _readStringMap(json['features']),
    );
  }
}

class UserSubscriptionDto {
  UserSubscriptionDto._();

  static UserSubscriptionEntity fromJson(Map<String, dynamic> json) {
    final usage = json['usage'] as Map<String, dynamic>? ?? const {};
    return UserSubscriptionEntity(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      startsAt: _readDate(json['startsAt']) ?? DateTime.now(),
      endsAt: _readDate(json['endsAt']) ?? DateTime.now(),
      canceledAt: _readDate(json['canceledAt']),
      autoRenew: json['autoRenew'] == true,
      reelsUsed: _readInt(usage['reelsUsed']),
      storiesUsed: _readInt(usage['storiesUsed']),
      portfolioUsed: _readInt(usage['portfolioUsed']),
      featuredUsed: _readInt(usage['featuredUsed']),
      plan: SubscriptionPlanDto.fromJson(json['plan'] as Map<String, dynamic>),
    );
  }
}

class SponsoredCampaignDto {
  SponsoredCampaignDto._();

  static SponsoredCampaignEntity fromJson(Map<String, dynamic> json) {
    final analytics = json['analytics'] as Map<String, dynamic>? ?? const {};
    return SponsoredCampaignEntity(
      id: json['id'] as String,
      ownerUserId: json['ownerUserId'] as String? ?? '',
      approvedByUserId: _readString(json['approvedByUserId']),
      subscriptionId: _readString(json['subscriptionId']),
      type: _readCampaignType(json['type'] as String? ?? 'promote_profile'),
      title: json['title'] as String? ?? 'Campaign',
      description: _readString(json['description']),
      status: _readCampaignStatus(json['status'] as String? ?? 'draft'),
      budgetTotal: _readDouble(json['budgetTotal']) ?? 0,
      dailyBudget: _readDouble(json['dailyBudget']) ?? 0,
      spentAmount: _readDouble(json['spentAmount']) ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      startsAt: _readDate(json['startsAt']) ?? DateTime.now(),
      endsAt: _readDate(json['endsAt']) ?? DateTime.now(),
      approvedAt: _readDate(json['approvedAt']),
      rejectedAt: _readDate(json['rejectedAt']),
      rejectionReason: _readString(json['rejectionReason']),
      targets: (json['targets'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CampaignTargetEntity(
              id: item['id'] as String? ?? '',
              targetType: item['targetType'] as String? ?? 'profile',
              entityId: item['entityId'] as String? ?? '',
            ),
          )
          .toList(growable: false),
      analytics: CampaignAnalyticsEntity(
        impressions: _readInt(analytics['impressions']),
        clicks: _readInt(analytics['clicks']),
        ctr: _readDouble(analytics['ctr']) ?? 0,
        spendAmount: _readDouble(analytics['spendAmount']) ?? 0,
      ),
      payments: (json['payments'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CampaignPaymentEntity(
              id: item['id'] as String? ?? '',
              amount: _readDouble(item['amount']) ?? 0,
              currency: item['currency'] as String? ?? 'USD',
              status: item['status'] as String? ?? 'pending',
              provider: item['provider'] as String? ?? 'pending',
              providerRef: _readString(item['providerRef']),
              paidAt: _readDate(item['paidAt']),
            ),
          )
          .toList(growable: false),
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(json['updatedAt']) ?? DateTime.now(),
    );
  }
}

class VenueBookingDto {
  VenueBookingDto._();

  static VenueBookingEntity fromJson(Map<String, dynamic> json) {
    return VenueBookingEntity(
      id: json['id'] as String,
      venueId: json['venueId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      eventDate: _readDate(json['eventDate']) ?? DateTime.now(),
      guestCount: json['guestCount'] == null
          ? null
          : _readInt(json['guestCount']),
      note: _readString(json['note']),
      priceAmount: _readDouble(json['priceAmount']),
      depositAmount: _readDouble(json['depositAmount']),
      currency: json['currency'] as String? ?? 'USD',
      createdAt: _readDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(json['updatedAt']) ?? DateTime.now(),
    );
  }
}

class UniqueId {
  static String fallback(String seed) =>
      '${seed}_${DateTime.now().microsecondsSinceEpoch}';
}
