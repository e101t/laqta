import 'package:laqta/core/models/photographer_model.dart' as core;
import 'package:laqta/core/models/portfolio_model.dart' as core;
import 'package:laqta/core/models/review_model.dart' as core;
import 'package:laqta/core/models/user_model.dart' as core;
import 'package:laqta/features/photographer/domain/entities/photographer_details.dart';
import 'package:laqta/features/photographer/domain/entities/photographer_review.dart';
import 'package:laqta/features/profile/domain/entities/portfolio.dart'
    as domain;
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/presentation/mappers/profile_presentation_mapper.dart';

class PhotographerPresentationMapper {
  static core.UserModel toUserModel(UserProfile profile) {
    return ProfilePresentationMapper.toUserModel(profile);
  }

  static core.PhotographerModel toPhotographerModel(
    PhotographerDetails details,
  ) {
    return core.PhotographerModel(
      uid: details.id,
      specialties: details.specialties,
      governorates: details.governorates,
      rate: details.rate,
      reviewsCount: details.reviewsCount,
      basePrice: details.basePrice,
      currency: details.currency,
      bio: details.bio,
      instagram: details.instagram,
      tiktok: details.tiktok,
      isVerified: details.isVerified,
      verifiedAt: details.verifiedAt,
      updatedAt: details.updatedAt,
    );
  }

  static core.PortfolioModel toPortfolioModel(domain.Portfolio portfolio) {
    return ProfilePresentationMapper.toPortfolioModel(portfolio);
  }

  static List<core.ReviewModel> toReviewModels(
    List<PhotographerReview> reviews,
  ) {
    return reviews
        .map(
          (review) => core.ReviewModel(
            id: review.id,
            bookingId: review.bookingId,
            reviewerId: review.reviewerId,
            targetId: review.targetId,
            rating: review.rating,
            qualityRating: review.qualityRating,
            communicationRating: review.communicationRating,
            onTimeRating: review.onTimeRating,
            deliverySpeedRating: review.deliverySpeedRating,
            recommend: review.recommend,
            comment: review.comment,
            createdAt: review.createdAt,
          ),
        )
        .toList();
  }
}
