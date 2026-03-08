import 'package:flutter/foundation.dart';
import 'package:luqta/features/trust/data/datasources/firestore_trust_remote_data_source.dart';
import 'package:luqta/features/trust/data/datasources/trust_remote_data_source.dart';
import 'package:luqta/features/trust/data/repositories/trust_repository_impl.dart';
import 'package:luqta/features/trust/domain/repositories/trust_repository.dart';
import 'package:luqta/features/trust/domain/usecases/get_trust_stats.dart';
import 'package:luqta/features/trust/domain/usecases/increment_canceled_by_photographer.dart';
import 'package:luqta/features/trust/domain/usecases/increment_completed_bookings.dart';
import 'package:luqta/features/trust/domain/usecases/increment_disputes_count.dart';
import 'package:luqta/features/trust/domain/usecases/increment_review_stats.dart';

class TrustDependencies {
  static final TrustRemoteDataSource _remoteDataSource =
      FirestoreTrustRemoteDataSource();
  static TrustRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(TrustRepository? repository) {
    _repositoryOverride = repository;
  }

  static TrustRepository get _repository =>
      _repositoryOverride ?? TrustRepositoryImpl(_remoteDataSource);

  static GetTrustStats getTrustStats() => GetTrustStats(_repository);

  static IncrementReviewStats incrementReviewStats() =>
      IncrementReviewStats(_repository);

  static IncrementCompletedBookings incrementCompletedBookings() =>
      IncrementCompletedBookings(_repository);

  static IncrementCanceledByPhotographer incrementCanceledByPhotographer() =>
      IncrementCanceledByPhotographer(_repository);

  static IncrementDisputesCount incrementDisputesCount() =>
      IncrementDisputesCount(_repository);
}
