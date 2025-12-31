import 'package:luqta/features/reels/data/datasources/firestore_reels_remote_data_source.dart';
import 'package:luqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:luqta/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:luqta/features/reels/domain/repositories/reels_repository.dart';
import 'package:luqta/features/reels/domain/usecases/add_reel_comment.dart';
import 'package:luqta/features/reels/domain/usecases/get_reel_comments.dart';
import 'package:luqta/features/reels/domain/usecases/get_reels.dart';
import 'package:luqta/features/reels/domain/usecases/update_reel_likes.dart';
import 'package:luqta/features/reels/domain/usecases/update_reel_shares.dart';

class ReelsDependencies {
  static final ReelsRemoteDataSource _remoteDataSource =
      FirestoreReelsRemoteDataSource();
  static final ReelsRepository _repository = ReelsRepositoryImpl(
    _remoteDataSource,
  );

  static GetReels getReels() => GetReels(_repository);

  static UpdateReelLikes updateReelLikes() => UpdateReelLikes(_repository);

  static UpdateReelShares updateReelShares() => UpdateReelShares(_repository);

  static GetReelComments getReelComments() => GetReelComments(_repository);

  static AddReelComment addReelComment() => AddReelComment(_repository);
}
