enum MarketplaceFeedKind { reel, photographer, venue, location }

enum MarketplaceCampaignType {
  promoteProfile,
  promoteReel,
  promoteStory,
  promoteVenue,
}

enum MarketplaceCampaignStatus {
  draft,
  pendingReview,
  approved,
  rejected,
  active,
  paused,
  completed,
}

class MarketplacePhotographerSummary {
  final String id;
  final String name;
  final String? photoUrl;
  final String? governorate;
  final String? bio;
  final List<String> specialties;
  final double? basePrice;
  final bool verified;
  final double? ratingAverage;
  final int ratingCount;
  final double rankingScore;

  const MarketplacePhotographerSummary({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.governorate,
    required this.bio,
    required this.specialties,
    required this.basePrice,
    required this.verified,
    required this.ratingAverage,
    required this.ratingCount,
    required this.rankingScore,
  });
}

class MarketplaceReelSummary {
  final String id;
  final String photographerId;
  final String photographerName;
  final String? photographerPhotoUrl;
  final String mediaId;
  final String mediaUrl;
  final String? caption;
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime createdAt;
  final double rankingScore;
  final bool isFeatured;
  final bool isSponsored;

  const MarketplaceReelSummary({
    required this.id,
    required this.photographerId,
    required this.photographerName,
    required this.photographerPhotoUrl,
    required this.mediaId,
    required this.mediaUrl,
    required this.caption,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.views,
    required this.createdAt,
    required this.rankingScore,
    required this.isFeatured,
    required this.isSponsored,
  });
}

class MarketplaceVenueMedia {
  final String id;
  final String mediaId;
  final String role;
  final String? caption;
  final int sortOrder;
  final String url;

  const MarketplaceVenueMedia({
    required this.id,
    required this.mediaId,
    required this.role,
    required this.caption,
    required this.sortOrder,
    required this.url,
  });
}

class MarketplaceVenueReview {
  final String id;
  final String userId;
  final int rating;
  final String? title;
  final String? comment;
  final DateTime createdAt;

  const MarketplaceVenueReview({
    required this.id,
    required this.userId,
    required this.rating,
    required this.title,
    required this.comment,
    required this.createdAt,
  });
}

class MarketplaceVenueAvailability {
  final String id;
  final DateTime date;
  final String status;
  final String? startTime;
  final String? endTime;
  final String? note;

  const MarketplaceVenueAvailability({
    required this.id,
    required this.date,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.note,
  });
}

class MarketplaceVenue {
  final String id;
  final String ownerUserId;
  final String type;
  final String name;
  final String slug;
  final String city;
  final String? area;
  final String? address;
  final String? description;
  final List<String> services;
  final String? contactPhone;
  final String? contactWhatsapp;
  final String? contactEmail;
  final double? latitude;
  final double? longitude;
  final int? capacityMin;
  final int? capacityMax;
  final double? pricingFrom;
  final double? pricingTo;
  final String pricingCurrency;
  final bool isFeatured;
  final DateTime? featuredUntil;
  final String verificationStatus;
  final double? ratingAverage;
  final int reviewCount;
  final String? coverMediaId;
  final String? coverUrl;
  final String? categoryName;
  final String? categorySlug;
  final List<MarketplaceVenueMedia> media;
  final List<MarketplaceVenueReview> reviews;
  final List<MarketplaceVenueAvailability> availability;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? rankingScore;

  const MarketplaceVenue({
    required this.id,
    required this.ownerUserId,
    required this.type,
    required this.name,
    required this.slug,
    required this.city,
    required this.area,
    required this.address,
    required this.description,
    required this.services,
    required this.contactPhone,
    required this.contactWhatsapp,
    required this.contactEmail,
    required this.latitude,
    required this.longitude,
    required this.capacityMin,
    required this.capacityMax,
    required this.pricingFrom,
    required this.pricingTo,
    required this.pricingCurrency,
    required this.isFeatured,
    required this.featuredUntil,
    required this.verificationStatus,
    required this.ratingAverage,
    required this.reviewCount,
    required this.coverMediaId,
    required this.coverUrl,
    required this.categoryName,
    required this.categorySlug,
    required this.media,
    required this.reviews,
    required this.availability,
    required this.createdAt,
    required this.updatedAt,
    required this.rankingScore,
  });

  bool get isLocationType =>
      type == 'studio' ||
      type == 'cafe' ||
      type == 'outdoor' ||
      type == 'hotel' ||
      type == 'garden';
}

class MarketplaceFeedEntry {
  final String id;
  final MarketplaceFeedKind kind;
  final double rankingScore;
  final bool isSponsored;
  final bool isFeatured;
  final MarketplaceReelSummary? reel;
  final MarketplacePhotographerSummary? photographer;
  final MarketplaceVenue? venue;

  const MarketplaceFeedEntry({
    required this.id,
    required this.kind,
    required this.rankingScore,
    required this.isSponsored,
    required this.isFeatured,
    this.reel,
    this.photographer,
    this.venue,
  });
}

class MarketplaceExploreData {
  final List<MarketplacePhotographerSummary> trendingPhotographers;
  final List<MarketplaceVenue> featuredVenues;
  final List<MarketplaceVenue> nearbyPlaces;
  final List<MarketplaceReelSummary> trendingReels;
  final List<MarketplacePhotographerSummary> recommendedCreators;

  const MarketplaceExploreData({
    required this.trendingPhotographers,
    required this.featuredVenues,
    required this.nearbyPlaces,
    required this.trendingReels,
    required this.recommendedCreators,
  });
}

class MarketplacePhotographerProfile {
  final String id;
  final String name;
  final String? photoUrl;
  final String? governorate;
  final String? bio;
  final List<String> specialties;
  final List<String> equipment;
  final List<String> coverageAreas;
  final double? basePrice;
  final bool verified;
  final String? instagramHandle;
  final double? ratingAverage;
  final int ratingCount;
  final int projectsCount;
  final int followersCount;
  final int followingCount;
  final List<MarketplaceMediaAsset> portfolio;
  final List<MarketplaceReelSummary> reels;
  final List<MarketplaceStoryAsset> stories;
  final double rankingScore;

  const MarketplacePhotographerProfile({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.governorate,
    required this.bio,
    required this.specialties,
    required this.equipment,
    required this.coverageAreas,
    required this.basePrice,
    required this.verified,
    required this.instagramHandle,
    required this.ratingAverage,
    required this.ratingCount,
    required this.projectsCount,
    required this.followersCount,
    required this.followingCount,
    required this.portfolio,
    required this.reels,
    required this.stories,
    required this.rankingScore,
  });
}

class MarketplaceMediaAsset {
  final String id;
  final String mediaId;
  final String url;
  final String mimeType;
  final DateTime createdAt;

  const MarketplaceMediaAsset({
    required this.id,
    required this.mediaId,
    required this.url,
    required this.mimeType,
    required this.createdAt,
  });
}

class MarketplaceStoryAsset {
  final String id;
  final String mediaId;
  final String mediaUrl;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  const MarketplaceStoryAsset({
    required this.id,
    required this.mediaId,
    required this.mediaUrl,
    required this.caption,
    required this.createdAt,
    required this.expiresAt,
  });
}

class SubscriptionPlanEntity {
  final String id;
  final String code;
  final String name;
  final String? description;
  final int reelsLimit;
  final int storiesLimit;
  final int portfolioLimit;
  final bool featuredEnabled;
  final bool analyticsEnabled;
  final int sponsoredDiscountPercent;
  final double priorityRankWeight;
  final bool isActive;
  final int sortOrder;
  final Map<String, String> features;

  const SubscriptionPlanEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.reelsLimit,
    required this.storiesLimit,
    required this.portfolioLimit,
    required this.featuredEnabled,
    required this.analyticsEnabled,
    required this.sponsoredDiscountPercent,
    required this.priorityRankWeight,
    required this.isActive,
    required this.sortOrder,
    required this.features,
  });
}

class UserSubscriptionEntity {
  final String id;
  final String userId;
  final String status;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? canceledAt;
  final bool autoRenew;
  final int reelsUsed;
  final int storiesUsed;
  final int portfolioUsed;
  final int featuredUsed;
  final SubscriptionPlanEntity plan;

  const UserSubscriptionEntity({
    required this.id,
    required this.userId,
    required this.status,
    required this.startsAt,
    required this.endsAt,
    required this.canceledAt,
    required this.autoRenew,
    required this.reelsUsed,
    required this.storiesUsed,
    required this.portfolioUsed,
    required this.featuredUsed,
    required this.plan,
  });
}

class SponsoredCampaignEntity {
  final String id;
  final String ownerUserId;
  final String? approvedByUserId;
  final String? subscriptionId;
  final MarketplaceCampaignType type;
  final String title;
  final String? description;
  final MarketplaceCampaignStatus status;
  final double budgetTotal;
  final double dailyBudget;
  final double spentAmount;
  final String currency;
  final DateTime startsAt;
  final DateTime endsAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final List<CampaignTargetEntity> targets;
  final CampaignAnalyticsEntity analytics;
  final List<CampaignPaymentEntity> payments;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SponsoredCampaignEntity({
    required this.id,
    required this.ownerUserId,
    required this.approvedByUserId,
    required this.subscriptionId,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    required this.budgetTotal,
    required this.dailyBudget,
    required this.spentAmount,
    required this.currency,
    required this.startsAt,
    required this.endsAt,
    required this.approvedAt,
    required this.rejectedAt,
    required this.rejectionReason,
    required this.targets,
    required this.analytics,
    required this.payments,
    required this.createdAt,
    required this.updatedAt,
  });
}

class CampaignTargetEntity {
  final String id;
  final String targetType;
  final String entityId;

  const CampaignTargetEntity({
    required this.id,
    required this.targetType,
    required this.entityId,
  });
}

class CampaignAnalyticsEntity {
  final int impressions;
  final int clicks;
  final double ctr;
  final double spendAmount;

  const CampaignAnalyticsEntity({
    required this.impressions,
    required this.clicks,
    required this.ctr,
    required this.spendAmount,
  });
}

class CampaignPaymentEntity {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String provider;
  final String? providerRef;
  final DateTime? paidAt;

  const CampaignPaymentEntity({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.provider,
    required this.providerRef,
    required this.paidAt,
  });
}

class VenueBookingEntity {
  final String id;
  final String venueId;
  final String userId;
  final String status;
  final DateTime eventDate;
  final int? guestCount;
  final String? note;
  final double? priceAmount;
  final double? depositAmount;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VenueBookingEntity({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.status,
    required this.eventDate,
    required this.guestCount,
    required this.note,
    required this.priceAmount,
    required this.depositAmount,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
  });
}
