import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/auth/data/datasources/auth_remote_data_source.dart';
import '../repositories/auth_repository.dart';

class StartRegistration {
  final AuthRepository _repository;

  const StartRegistration(this._repository);

  Future<Result<AuthOtpStartDto>> call({
    required String role,
    required String firstName,
    required String lastName,
    required String username,
    required String gender,
    required String birthdate,
    required String province,
    required String phone,
  }) {
    return _repository.startRegistration(
      role: role,
      firstName: firstName,
      lastName: lastName,
      username: username,
      gender: gender,
      birthdate: birthdate,
      province: province,
      phone: phone,
    );
  }
}
