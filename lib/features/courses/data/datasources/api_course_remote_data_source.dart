import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:laqta/features/courses/data/dtos/course_dto.dart';

/// REST-backed implementation, mirroring
/// lib/features/requests/data/datasources/api_requests_remote_data_source.dart's
/// call/DTO style. Replaces FirestoreCourseRemoteDataSource, which talked to
/// the inert lib/core/utils/legacy_data_compat.dart stub and never actually
/// persisted anything.
class ApiCourseRemoteDataSource implements CourseRemoteDataSource {
  final BackendApiClient _apiClient;

  ApiCourseRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  @override
  Future<List<CourseDto>> listPublishedCourses({String? specialty}) async {
    final response = await _apiClient.get(
      specialty == null || specialty.isEmpty
          ? '/courses'
          : '/courses?specialty=${Uri.encodeQueryComponent(specialty)}',
    );
    return _readList(response, 'courses')
        .map((json) => CourseDto.fromJson(json))
        .toList();
  }

  @override
  Future<List<CourseDto>> getCoursesByPhotographer(
    String photographerId,
  ) async {
    final response = await _apiClient.get('/courses/photographer/$photographerId');
    return _readList(response, 'courses')
        .map((json) => CourseDto.fromJson(json))
        .toList();
  }

  @override
  Future<CourseDto> getCourseById(String courseId) async {
    final response = await _apiClient.get('/courses/$courseId');
    return CourseDto.fromJson(_readMap(response, 'course'));
  }

  @override
  Future<String> createCourse(CourseDto course) async {
    final response = await _apiClient.post(
      '/courses',
      body: course.toBackendCreateJson(),
    );
    final created = _readMap(response, 'course');
    final id = created['id'];
    if (id is! String || id.isEmpty) {
      throw const BackendApiException('Backend did not return a course id.');
    }
    return id;
  }

  @override
  Future<void> updateCourse(String courseId, CourseDto course) async {
    await _apiClient.patch(
      '/courses/$courseId',
      body: course.toBackendCreateJson(),
    );
  }

  @override
  Future<void> deleteCourse(String courseId) async {
    await _apiClient.delete('/courses/$courseId');
  }

  List<Map<String, dynamic>> _readList(dynamic response, String key) {
    if (response is Map<String, dynamic>) {
      final value = response[key];
      if (value is List) {
        return value
            .whereType<Map<Object?, Object?>>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }
    if (response is List) {
      return response
          .whereType<Map<Object?, Object?>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    throw const BackendApiException('Unexpected backend response format.');
  }

  Map<String, dynamic> _readMap(dynamic response, String key) {
    if (response is Map<String, dynamic>) {
      final nested = response[key];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      if (nested is Map) {
        return Map<String, dynamic>.from(nested);
      }
      // Some endpoints may return the entity directly, unwrapped.
      if (response.containsKey('id')) {
        return response;
      }
    }
    throw const BackendApiException('Unexpected backend response format.');
  }
}
