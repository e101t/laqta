import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/courses/data/datasources/course_enrollment_remote_data_source.dart';
import 'package:laqta/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:laqta/features/courses/data/mappers/course_enrollment_mapper.dart';
import 'package:laqta/features/courses/data/mappers/course_mapper.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';
import 'package:laqta/features/courses/domain/entities/course_enrollment.dart';
import 'package:laqta/features/courses/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements CourseRepository {
  final CourseRemoteDataSource _courseDataSource;
  final CourseEnrollmentRemoteDataSource _enrollmentDataSource;

  const CourseRepositoryImpl(
    this._courseDataSource,
    this._enrollmentDataSource,
  );

  @override
  Future<Result<List<Course>>> listPublishedCourses({
    String? specialty,
  }) async {
    try {
      final dtos = await _courseDataSource.listPublishedCourses(
        specialty: specialty,
      );
      return Result.success(dtos.map(CourseMapper.toDomain).toList());
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load courses'));
    }
  }

  @override
  Future<Result<List<Course>>> getCoursesByPhotographer(
    String photographerId,
  ) async {
    try {
      final dtos = await _courseDataSource.getCoursesByPhotographer(
        photographerId,
      );
      return Result.success(dtos.map(CourseMapper.toDomain).toList());
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load courses'));
    }
  }

  @override
  Future<Result<Course>> getCourseById(String courseId) async {
    try {
      final dto = await _courseDataSource.getCourseById(courseId);
      return Result.success(CourseMapper.toDomain(dto));
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to load course'));
    }
  }

  @override
  Future<Result<String>> createCourse(Course course) async {
    try {
      final dto = CourseMapper.toDto(course);
      final id = await _courseDataSource.createCourse(dto);
      return Result.success(id);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to create course'));
    }
  }

  @override
  Future<Result<void>> updateCourse(Course course) async {
    try {
      final dto = CourseMapper.toDto(course);
      await _courseDataSource.updateCourse(course.id, dto);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to update course'));
    }
  }

  @override
  Future<Result<void>> deleteCourse(String courseId) async {
    try {
      await _courseDataSource.deleteCourse(courseId);
      return Result.success(null);
    } catch (_) {
      return Result.failure(const Failure(message: 'Failed to delete course'));
    }
  }

  @override
  Future<Result<String>> enrollInCourse(String courseId) async {
    try {
      final enrollmentId = await _enrollmentDataSource.createEnrollment(
        courseId,
      );
      return Result.success(enrollmentId);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to enroll in course'),
      );
    }
  }

  @override
  Future<Result<CourseEnrollmentPaymentIntent>> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  }) async {
    try {
      final dto = await _enrollmentDataSource.createEnrollmentPaymentIntent(
        enrollmentId: enrollmentId,
        amount: amount,
        currency: currency,
      );
      return Result.success(
        CourseEnrollmentPaymentIntent(
          paymentIntentId: dto.paymentIntentId,
          clientSecret: dto.clientSecret,
        ),
      );
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to create payment intent'),
      );
    }
  }

  @override
  Future<Result<void>> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  }) async {
    try {
      await _enrollmentDataSource.confirmEnrollmentPayment(
        enrollmentId: enrollmentId,
        paymentIntentId: paymentIntentId,
        amount: amount,
      );
      return Result.success(null);
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to confirm payment'),
      );
    }
  }

  @override
  Future<Result<List<CourseEnrollment>>> getMyEnrollments(
    String customerId,
  ) async {
    try {
      final dtos = await _enrollmentDataSource.getMyEnrollments(customerId);
      return Result.success(dtos.map(CourseEnrollmentMapper.toDomain).toList());
    } catch (_) {
      return Result.failure(
        const Failure(message: 'Failed to load enrollments'),
      );
    }
  }
}
