import 'package:laqta/core/domain/result/result.dart';
import '../repositories/reels_repository.dart';

class UploadReelMedia {
  final ReelsRepository _repository;

  const UploadReelMedia(this._repository);

  Future<Result<String>> call({
    required String photographerId,
    required String reelId,
    required String filePath,
    required String contentType,
  }) {
    return _repository.uploadReelMedia(
      photographerId: photographerId,
      reelId: reelId,
      filePath: filePath,
      contentType: contentType,
    );
  }
}
