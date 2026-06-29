import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/features/courses/data/datasources/course_enrollment_remote_data_source.dart';
import 'package:laqta/features/courses/data/dtos/course_enrollment_dto.dart';

/// Calls the backend's course-enrollment REST endpoints (mirrors
/// [StripeService]'s REST call style for booking payments). The same
/// endpoint paths must be implemented backend-side, equivalent to the
/// `createCourseEnrollment` / `createCourseEnrollmentPaymentIntent` /
/// `confirmCourseEnrollmentPayment` Cloud Functions in functions/index.js.
class BackendCourseEnrollmentRemoteDataSource
    implements CourseEnrollmentRemoteDataSource {
  BackendCourseEnrollmentRemoteDataSource({BackendApiClient? apiClient})
    : _apiClient = apiClient ?? BackendApiClient();

  final BackendApiClient _apiClient;

  @override
  Future<String> createEnrollment(String courseId) async {
    final response = await _apiClient.post(
      '/courses/enrollments',
      body: {'courseId': courseId},
    );
    if (response is! Map<String, dynamic> ||
        response['enrollmentId'] is! String) {
      throw const BackendApiException('Invalid enrollment response.');
    }
    return response['enrollmentId'] as String;
  }

  @override
  Future<CourseEnrollmentPaymentIntentDto> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  }) async {
    final response = await _apiClient.post(
      '/payments/course-enrollments/payment-intents',
      body: {
        'enrollmentId': enrollmentId,
        'amount': amount,
        'currency': currency,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const BackendApiException('Invalid payment intent response.');
    }
    final data = response['paymentIntent'] is Map
        ? Map<String, dynamic>.from(response['paymentIntent'] as Map)
        : response;
    return CourseEnrollmentPaymentIntentDto.fromMap(data);
  }

  @override
  Future<void> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  }) async {
    await _apiClient.post(
      '/payments/course-enrollments/payment-intents/confirm',
      body: {
        'enrollmentId': enrollmentId,
        'paymentIntentId': paymentIntentId,
        'amount': amount,
      },
    );
  }

  @override
  Future<List<CourseEnrollmentDto>> getMyEnrollments(String customerId) async {
    final response = await _apiClient.get('/courses/enrollments/my');
    return _readList(response, 'enrollments')
        .map((json) => CourseEnrollmentDto.fromJson(json))
        .toList();
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
}
