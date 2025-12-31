import 'package:luqta/features/review/data/dtos/review_dto.dart';

abstract class ReviewRemoteDataSource {
  Future<void> submitReview(ReviewDto review);
}
