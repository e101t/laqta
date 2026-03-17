import 'package:laqta/features/photographer/data/dtos/photographer_dto.dart';
import 'package:laqta/features/photographer/domain/entities/photographer_details.dart';
import 'package:laqta/features/photographer/domain/entities/photographer_review.dart';
import 'package:laqta/features/profile/data/dtos/portfolio_dto.dart';
import 'package:laqta/features/profile/data/dtos/user_profile_dto.dart';
import 'package:laqta/features/profile/data/mappers/profile_mapper.dart';
import 'package:laqta/features/profile/domain/entities/portfolio.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';

class PhotographerMapper {
  static PhotographerDetails toDomainDetails(PhotographerDetailsDto dto) {
    return PhotographerDetails(
      id: dto.id,
      specialties: dto.specialties,
      governorates: dto.governorates,
      rate: dto.rate,
      reviewsCount: dto.reviewsCount,
      basePrice: dto.basePrice,
      currency: dto.currency,
      bio: dto.bio,
      instagram: dto.instagram,
      tiktok: dto.tiktok,
      isVerified: dto.isVerified,
      verifiedAt: dto.verifiedAt,
      updatedAt: dto.updatedAt,
    );
  }

  static PhotographerReview toDomainReview(PhotographerReviewDto dto) {
    return PhotographerReview(
      id: dto.id,
      bookingId: dto.bookingId,
      reviewerId: dto.reviewerId,
      targetId: dto.targetId,
      rating: dto.rating,
      qualityRating: dto.qualityRating,
      communicationRating: dto.communicationRating,
      onTimeRating: dto.onTimeRating,
      deliverySpeedRating: dto.deliverySpeedRating,
      recommend: dto.recommend,
      comment: dto.comment,
      createdAt: dto.createdAt,
    );
  }

  static UserProfile toDomainUser(UserProfileDto dto) {
    return ProfileMapper.toDomain(dto);
  }

  static Portfolio toDomainPortfolio(PortfolioDto dto) {
    return ProfileMapper.toDomainPortfolio(dto);
  }
}
