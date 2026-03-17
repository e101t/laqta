import 'package:laqta/features/role/data/datasources/firestore_role_remote_data_source.dart';
import 'package:laqta/features/role/data/datasources/role_remote_data_source.dart';
import 'package:laqta/features/role/data/repositories/role_repository_impl.dart';
import 'package:laqta/features/role/domain/repositories/role_repository.dart';
import 'package:laqta/features/role/domain/usecases/save_user_role.dart';

class RoleDependencies {
  static final RoleRemoteDataSource _remoteDataSource =
      FirestoreRoleRemoteDataSource();
  static final RoleRepository _repository = RoleRepositoryImpl(
    _remoteDataSource,
  );

  static SaveUserRole saveUserRole() => SaveUserRole(_repository);
}
