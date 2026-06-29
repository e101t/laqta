import 'package:laqta/features/courses/data/dtos/course_enrollment_dto.dart';

class CourseEnrollmentPaymentIntentDto {
  final String paymentIntentId;
  final String clientSecret;

  const CourseEnrollmentPaymentIntentDto({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  factory CourseEnrollmentPaymentIntentDto.fromMap(Map<String, dynamic> data) {
    return CourseEnrollmentPaymentIntentDto(
      paymentIntentId: data['paymentIntentId'] as String? ?? '',
      clientSecret: data['clientSecret'] as String? ?? '',
    );
  }
}

abstract class CourseEnrollmentRemoteDataSource {
  /// Reserves a seat for the signed-in customer. Returns the new enrollment id.
  Future<String> createEnrollment(String courseId);

  Future<CourseEnrollmentPaymentIntentDto> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  });

  Future<void> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  });

  Future<List<CourseEnrollmentDto>> getMyEnrollments(String customerId);
}
