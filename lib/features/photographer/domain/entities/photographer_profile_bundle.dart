import 'package:luqta/features/profile/domain/entities/portfolio.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';
import 'photographer_details.dart';
import 'photographer_review.dart';

class PhotographerProfileBundle {
  final UserProfile user;
  final PhotographerDetails photographer;
  final Portfolio? portfolio;
  final List<PhotographerReview> reviews;

  const PhotographerProfileBundle({
    required this.user,
    required this.photographer,
    this.portfolio,
    required this.reviews,
  });
}
