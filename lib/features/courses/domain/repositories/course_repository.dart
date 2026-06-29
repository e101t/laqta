import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../entities/course_enrollment.dart';

abstract class CourseRepository {
  Future<Result<List<Course>>> listPublishedCourses({String? specialty});

  Future<Result<List<Course>>> getCoursesByPhotographer(String photographerId);

  Future<Result<Course>> getCourseById(String courseId);

  Future<Result<String>> createCourse(Course course);

  Future<Result<void>> updateCourse(Course course);

  Future<Result<void>> deleteCourse(String courseId);

  Future<Result<String>> enrollInCourse(String courseId);

  Future<Result<CourseEnrollmentPaymentIntent>> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  });

  Future<Result<void>> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  });

  Future<Result<List<CourseEnrollment>>> getMyEnrollments(String customerId);
}

class CourseEnrollmentPaymentIntent {
  final String paymentIntentId;
  final String clientSecret;

  const CourseEnrollmentPaymentIntent({
    required this.paymentIntentId,
    required this.clientSecret,
  });
}
