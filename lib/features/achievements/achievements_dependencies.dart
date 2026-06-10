import 'package:laqta/features/achievements/data/datasources/achievements_remote_data_source.dart';
import 'package:laqta/features/achievements/data/datasources/firestore_achievements_remote_data_source.dart';
import 'package:laqta/features/achievements/data/repositories/achievements_repository_impl.dart';
import 'package:laqta/features/achievements/domain/repositories/achievements_repository.dart';
import 'package:laqta/features/achievements/domain/usecases/get_user_achievements.dart';

class AchievementsDependencies {
  static final AchievementsRemoteDataSource _remoteDataSource =
      FirestoreAchievementsRemoteDataSource();
  static final AchievementsRepository _repository = AchievementsRepositoryImpl(
    _remoteDataSource,
  );

  static GetUserAchievements getUserAchievements() =>
      GetUserAchievements(_repository);
}
