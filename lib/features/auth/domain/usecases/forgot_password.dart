import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import '../repositories/auth_repository.dart';

class ForgotPassword {
  final AuthRepository _repository;

  const ForgotPassword(this._repository);

  Future<Result<AuthOtpStartDto>> call({required String phone}) {
    return _repository.forgotPassword(phone: phone);
  }
}
