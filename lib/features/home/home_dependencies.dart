import 'package:luqta/features/home/data/datasources/firestore_home_remote_data_source.dart';
import 'package:luqta/features/home/data/datasources/home_remote_data_source.dart';
import 'package:luqta/features/home/data/repositories/home_repository_impl.dart';
import 'package:luqta/features/home/domain/repositories/home_repository.dart';
import 'package:luqta/features/home/domain/usecases/get_active_stories.dart';
import 'package:luqta/features/home/domain/usecases/get_following_ids.dart';
import 'package:luqta/features/home/domain/usecases/get_home_photographers.dart';
import 'package:luqta/features/home/domain/usecases/record_story_view.dart';
import 'package:luqta/features/home/domain/usecases/set_follow_status.dart';

class HomeDependencies {
  static final HomeRemoteDataSource _remoteDataSource =
      FirestoreHomeRemoteDataSource();
  static final HomeRepository _repository = HomeRepositoryImpl(
    _remoteDataSource,
  );

  static GetActiveStories getActiveStories() => GetActiveStories(_repository);

  static RecordStoryView recordStoryView() => RecordStoryView(_repository);

  static GetHomePhotographers getHomePhotographers() =>
      GetHomePhotographers(_repository);

  static GetFollowingIds getFollowingIds() => GetFollowingIds(_repository);

  static SetFollowStatus setFollowStatus() => SetFollowStatus(_repository);
}
