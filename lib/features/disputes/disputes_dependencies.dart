import 'package:laqta/core/services/backend_config.dart';
import 'package:laqta/features/disputes/data/datasources/api_disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/datasources/disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/datasources/firestore_disputes_remote_data_source.dart';
import 'package:laqta/features/disputes/data/repositories/disputes_repository_impl.dart';
import 'package:laqta/features/disputes/domain/repositories/disputes_repository.dart';
import 'package:laqta/features/disputes/domain/usecases/create_dispute.dart';
import 'package:laqta/features/disputes/domain/usecases/get_dispute_by_booking.dart';
import 'package:laqta/features/disputes/domain/usecases/get_disputes_for_user.dart';
import 'package:laqta/features/disputes/domain/usecases/get_open_disputes.dart';
import 'package:laqta/features/disputes/domain/usecases/update_dispute.dart';

class DisputesDependencies {
  static DisputesRemoteDataSource? _remoteDataSource;
  static DisputesRepository? _repository;

  static DisputesRemoteDataSource get _remote =>
      _remoteDataSource ??= (BackendConfig.useBackendDisputes
      ? ApiDisputesRemoteDataSource()
      : FirestoreDisputesRemoteDataSource());

  static DisputesRepository get _resolvedRepository =>
      _repository ??= DisputesRepositoryImpl(_remote);

  static GetDisputeByBooking getDisputeByBooking() =>
      GetDisputeByBooking(_resolvedRepository);

  static GetDisputesForUser getDisputesForUser() =>
      GetDisputesForUser(_resolvedRepository);

  static GetOpenDisputes getOpenDisputes() =>
      GetOpenDisputes(_resolvedRepository);

  static CreateDispute createDispute() => CreateDispute(_resolvedRepository);

  static UpdateDispute updateDispute() => UpdateDispute(_resolvedRepository);
}
