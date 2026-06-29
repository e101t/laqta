import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/features/courses/data/datasources/course_enrollment_remote_data_source.dart';
import 'package:laqta/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:laqta/features/courses/data/dtos/course_dto.dart';
import 'package:laqta/features/courses/data/dtos/course_enrollment_dto.dart';
import 'package:laqta/features/courses/data/repositories/course_repository_impl.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';

class _FakeCourseRemoteDataSource implements CourseRemoteDataSource {
  _FakeCourseRemoteDataSource({
    this.courses = const [],
    this.throwOnList = false,
    this.throwOnCreate = false,
  });

  final List<CourseDto> courses;
  final bool throwOnList;
  final bool throwOnCreate;
  String? lastCreatedCourseId;

  @override
  Future<List<CourseDto>> listPublishedCourses({String? specialty}) async {
    if (throwOnList) throw StateError('network error');
    return courses;
  }

  @override
  Future<List<CourseDto>> getCoursesByPhotographer(
    String photographerId,
  ) async {
    return courses.where((c) => c.photographerId == photographerId).toList();
  }

  @override
  Future<CourseDto> getCourseById(String courseId) async {
    return courses.firstWhere((c) => c.id == courseId);
  }

  @override
  Future<String> createCourse(CourseDto course) async {
    if (throwOnCreate) throw StateError('failed to write');
    lastCreatedCourseId = 'new_course_id';
    return lastCreatedCourseId!;
  }

  @override
  Future<void> updateCourse(String courseId, CourseDto course) async {}

  @override
  Future<void> deleteCourse(String courseId) async {}
}

class _FakeCourseEnrollmentRemoteDataSource
    implements CourseEnrollmentRemoteDataSource {
  _FakeCourseEnrollmentRemoteDataSource({this.throwOnConfirm = false});

  final bool throwOnConfirm;
  String? lastEnrolledCourseId;
  bool confirmCalled = false;

  @override
  Future<String> createEnrollment(String courseId) async {
    lastEnrolledCourseId = courseId;
    return 'enrollment_1';
  }

  @override
  Future<CourseEnrollmentPaymentIntentDto> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  }) async {
    return const CourseEnrollmentPaymentIntentDto(
      paymentIntentId: 'pi_1',
      clientSecret: 'secret_1',
    );
  }

  @override
  Future<void> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  }) async {
    if (throwOnConfirm) throw StateError('confirm failed');
    confirmCalled = true;
  }

  @override
  Future<List<CourseEnrollmentDto>> getMyEnrollments(String customerId) async {
    return const [];
  }
}

void main() {
  group('CourseRepositoryImpl', () {
    test('listPublishedCourses maps datasource DTOs to domain entities', () async {
      final now = DateTime.utc(2026, 1, 1);
      final courseDataSource = _FakeCourseRemoteDataSource(
        courses: [
          CourseDto(
            id: 'course_1',
            photographerId: 'photog_1',
            title: 'Course 1',
            description: 'desc',
            type: 'in_person',
            specialties: const ['Wedding'],
            basePrice: 1000,
            currency: 'IQD',
            capacity: 5,
            seatsRemaining: 5,
            sessions: const [],
            isPublished: true,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );
      final repository = CourseRepositoryImpl(
        courseDataSource,
        _FakeCourseEnrollmentRemoteDataSource(),
      );

      final result = await repository.listPublishedCourses();

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, hasLength(1));
      expect(result.valueOrNull!.first.title, 'Course 1');
    });

    test(
      'listPublishedCourses wraps datasource exceptions in Result.failure',
      () async {
        final repository = CourseRepositoryImpl(
          _FakeCourseRemoteDataSource(throwOnList: true),
          _FakeCourseEnrollmentRemoteDataSource(),
        );

        final result = await repository.listPublishedCourses();

        expect(result.isSuccess, isFalse);
        expect(result.failureOrNull?.message, 'Failed to load courses');
      },
    );

    test('createCourse returns the new id on success', () async {
      final courseDataSource = _FakeCourseRemoteDataSource();
      final repository = CourseRepositoryImpl(
        courseDataSource,
        _FakeCourseEnrollmentRemoteDataSource(),
      );
      final now = DateTime.utc(2026, 1, 1);

      final result = await repository.createCourse(
        _course(now: now, id: ''),
      );

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 'new_course_id');
      expect(courseDataSource.lastCreatedCourseId, 'new_course_id');
    });

    test('createCourse wraps datasource exceptions in Result.failure', () async {
      final repository = CourseRepositoryImpl(
        _FakeCourseRemoteDataSource(throwOnCreate: true),
        _FakeCourseEnrollmentRemoteDataSource(),
      );
      final now = DateTime.utc(2026, 1, 1);

      final result = await repository.createCourse(_course(now: now, id: ''));

      expect(result.isSuccess, isFalse);
      expect(result.failureOrNull?.message, 'Failed to create course');
    });

    test('enrollInCourse delegates to the enrollment data source', () async {
      final enrollmentDataSource = _FakeCourseEnrollmentRemoteDataSource();
      final repository = CourseRepositoryImpl(
        _FakeCourseRemoteDataSource(),
        enrollmentDataSource,
      );

      final result = await repository.enrollInCourse('course_1');

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 'enrollment_1');
      expect(enrollmentDataSource.lastEnrolledCourseId, 'course_1');
    });

    test(
      'confirmEnrollmentPayment surfaces datasource failures without throwing',
      () async {
        final repository = CourseRepositoryImpl(
          _FakeCourseRemoteDataSource(),
          _FakeCourseEnrollmentRemoteDataSource(throwOnConfirm: true),
        );

        final result = await repository.confirmEnrollmentPayment(
          enrollmentId: 'enrollment_1',
          paymentIntentId: 'pi_1',
          amount: 1000,
        );

        expect(result.isSuccess, isFalse);
        expect(result.failureOrNull?.message, 'Failed to confirm payment');
      },
    );
  });
}

Course _course({required DateTime now, required String id}) {
  return Course(
    id: id,
    photographerId: 'photog_1',
    title: 'New course',
    description: 'desc',
    type: 'in_person',
    specialties: const [],
    basePrice: 1000,
    currency: 'IQD',
    capacity: 5,
    seatsRemaining: 5,
    sessions: const [],
    isPublished: false,
    createdAt: now,
    updatedAt: now,
  );
}
