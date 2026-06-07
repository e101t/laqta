import 'package:laqta/features/reels/data/datasources/api_reels_remote_data_source.dart';
import 'package:flutter/foundation.dart';
import 'package:laqta/features/reels/data/datasources/reels_remote_data_source.dart';
import 'package:laqta/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:laqta/features/reels/domain/repositories/reels_repository.dart';
import 'package:laqta/features/reels/domain/usecases/add_reel_comment.dart';
import 'package:laqta/features/reels/domain/usecases/create_reel.dart';
import 'package:laqta/features/reels/domain/usecases/get_reel_comments.dart';
import 'package:laqta/features/reels/domain/usecases/get_reels.dart';
import 'package:laqta/features/reels/domain/usecases/upload_reel_media.dart';
import 'package:laqta/features/reels/domain/usecases/update_reel_likes.dart';
import 'package:laqta/features/reels/domain/usecases/update_reel_shares.dart';

class ReelsDependencies {
  static final ReelsRemoteDataSource _remoteDataSource =
      ApiReelsRemoteDataSource();
  static ReelsRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(ReelsRepository? repository) {
    _repositoryOverride = repository;
  }

  static ReelsRepository get _repository =>
      _repositoryOverride ?? ReelsRepositoryImpl(_remoteDataSource);

  static GetReels getReels() => GetReels(_repository);

  static CreateReel createReel() => CreateReel(_repository);

  static UploadReelMedia uploadReelMedia() => UploadReelMedia(_repository);

  static UpdateReelLikes updateReelLikes() => UpdateReelLikes(_repository);

  static UpdateReelShares updateReelShares() => UpdateReelShares(_repository);

  static GetReelComments getReelComments() => GetReelComments(_repository);

  static AddReelComment addReelComment() => AddReelComment(_repository);
}
