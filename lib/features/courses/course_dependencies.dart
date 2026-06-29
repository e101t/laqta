import 'package:flutter/foundation.dart';
import 'package:laqta/features/courses/data/datasources/backend_course_enrollment_remote_data_source.dart';
import 'package:laqta/features/courses/data/datasources/course_enrollment_remote_data_source.dart';
import 'package:laqta/features/courses/data/datasources/course_remote_data_source.dart';
import 'package:laqta/features/courses/data/datasources/firestore_course_remote_data_source.dart';
import 'package:laqta/features/courses/data/repositories/course_repository_impl.dart';
import 'package:laqta/features/courses/domain/repositories/course_repository.dart';
import 'package:laqta/features/courses/domain/usecases/confirm_enrollment_payment.dart';
import 'package:laqta/features/courses/domain/usecases/create_course.dart';
import 'package:laqta/features/courses/domain/usecases/create_enrollment_payment_intent.dart';
import 'package:laqta/features/courses/domain/usecases/delete_course.dart';
import 'package:laqta/features/courses/domain/usecases/enroll_in_course.dart';
import 'package:laqta/features/courses/domain/usecases/get_course_by_id.dart';
import 'package:laqta/features/courses/domain/usecases/get_courses_by_photographer.dart';
import 'package:laqta/features/courses/domain/usecases/get_my_enrollments.dart';
import 'package:laqta/features/courses/domain/usecases/list_published_courses.dart';
import 'package:laqta/features/courses/domain/usecases/update_course.dart';

class CourseDependencies {
  static final CourseRemoteDataSource _courseDataSource =
      FirestoreCourseRemoteDataSource();
  static final CourseEnrollmentRemoteDataSource _enrollmentDataSource =
      BackendCourseEnrollmentRemoteDataSource();
  static CourseRepository? _repositoryOverride;

  @visibleForTesting
  static void setRepositoryOverride(CourseRepository? repository) {
    _repositoryOverride = repository;
  }

  static CourseRepository get _repository =>
      _repositoryOverride ??
      CourseRepositoryImpl(_courseDataSource, _enrollmentDataSource);

  static ListPublishedCourses listPublishedCourses() =>
      ListPublishedCourses(_repository);

  static GetCoursesByPhotographer getCoursesByPhotographer() =>
      GetCoursesByPhotographer(_repository);

  static GetCourseById getCourseById() => GetCourseById(_repository);

  static CreateCourse createCourse() => CreateCourse(_repository);

  static UpdateCourse updateCourse() => UpdateCourse(_repository);

  static DeleteCourse deleteCourse() => DeleteCourse(_repository);

  static EnrollInCourse enrollInCourse() => EnrollInCourse(_repository);

  static CreateEnrollmentPaymentIntent createEnrollmentPaymentIntent() =>
      CreateEnrollmentPaymentIntent(_repository);

  static ConfirmEnrollmentPayment confirmEnrollmentPayment() =>
      ConfirmEnrollmentPayment(_repository);

  static GetMyEnrollments getMyEnrollments() => GetMyEnrollments(_repository);
}
