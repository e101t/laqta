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
  static final DisputesRemoteDataSource _remoteDataSource =
      FirestoreDisputesRemoteDataSource();
  static final DisputesRepository _repository = DisputesRepositoryImpl(
    _remoteDataSource,
  );

  static GetDisputeByBooking getDisputeByBooking() =>
      GetDisputeByBooking(_repository);

  static GetDisputesForUser getDisputesForUser() =>
      GetDisputesForUser(_repository);

  static GetOpenDisputes getOpenDisputes() => GetOpenDisputes(_repository);

  static CreateDispute createDispute() => CreateDispute(_repository);

  static UpdateDispute updateDispute() => UpdateDispute(_repository);
}
