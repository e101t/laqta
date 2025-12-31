import 'package:luqta/features/review/data/datasources/firestore_review_remote_data_source.dart';
import 'package:luqta/features/review/data/datasources/review_remote_data_source.dart';
import 'package:luqta/features/review/data/repositories/review_repository_impl.dart';
import 'package:luqta/features/review/domain/repositories/review_repository.dart';
import 'package:luqta/features/review/domain/usecases/submit_review.dart';

class ReviewDependencies {
  static final ReviewRemoteDataSource _remoteDataSource =
      FirestoreReviewRemoteDataSource();
  static final ReviewRepository _repository = ReviewRepositoryImpl(
    _remoteDataSource,
  );

  static SubmitReview submitReview() => SubmitReview(_repository);
}
