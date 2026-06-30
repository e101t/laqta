import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/review/data/datasources/review_remote_data_source.dart';
import 'package:laqta/features/review/data/dtos/review_dto.dart';

class ApiReviewRemoteDataSource implements ReviewRemoteDataSource {
  ApiReviewRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<void> submitReview(ReviewDto review) async {
    await _apiClient.post('/reviews', body: review.toJson());
  }
}
