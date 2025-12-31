import 'package:luqta/core/domain/result/result.dart';
import '../repositories/home_repository.dart';

class RecordStoryView {
  final HomeRepository _repository;

  const RecordStoryView(this._repository);

  Future<Result<void>> call({required String storyId, required String userId}) {
    return _repository.recordStoryView(storyId: storyId, userId: userId);
  }
}
