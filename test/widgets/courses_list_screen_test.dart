import 'package:flutter_test/flutter_test.dart';
import 'package:laqta/core/domain/failures/failure.dart';
import 'package:laqta/core/domain/result/result.dart';
import 'package:laqta/features/courses/course_dependencies.dart';
import 'package:laqta/features/courses/domain/entities/course.dart';
import 'package:laqta/features/courses/domain/entities/course_enrollment.dart';
import 'package:laqta/features/courses/domain/repositories/course_repository.dart';
import 'package:laqta/features/courses/presentation/screens/courses_list_screen.dart';
import '../helpers/test_app.dart';

class _FakeCourseRepository implements CourseRepository {
  _FakeCourseRepository({this.courses, this.shouldFail = false});

  final List<Course>? courses;
  final bool shouldFail;

  @override
  Future<Result<List<Course>>> listPublishedCourses({String? specialty}) async {
    if (shouldFail) {
      return Result.failure(const Failure(message: 'boom'));
    }
    return Result.success(courses ?? const []);
  }

  @override
  Future<Result<List<Course>>> getCoursesByPhotographer(
    String photographerId,
  ) async => Result.success(const []);

  @override
  Future<Result<Course>> getCourseById(String courseId) async =>
      Result.failure(const Failure(message: 'not used in this test'));

  @override
  Future<Result<String>> createCourse(Course course) async =>
      Result.success('id');

  @override
  Future<Result<void>> updateCourse(Course course) async => Result.success(null);

  @override
  Future<Result<void>> deleteCourse(String courseId) async =>
      Result.success(null);

  @override
  Future<Result<String>> enrollInCourse(String courseId) async =>
      Result.success('enrollment_1');

  @override
  Future<Result<CourseEnrollmentPaymentIntent>> createEnrollmentPaymentIntent({
    required String enrollmentId,
    required double amount,
    required String currency,
  }) async => Result.failure(const Failure(message: 'not used in this test'));

  @override
  Future<Result<void>> confirmEnrollmentPayment({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  }) async => Result.success(null);

  @override
  Future<Result<List<CourseEnrollment>>> getMyEnrollments(
    String customerId,
  ) async => Result.success(const []);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Course buildCourse({
    required String id,
    required String title,
    int seatsRemaining = 5,
  }) {
    final now = DateTime(2026, 1, 1);
    return Course(
      id: id,
      photographerId: 'photog_1',
      title: title,
      description: 'desc',
      type: 'in_person',
      specialties: const ['Wedding'],
      basePrice: 50000,
      currency: 'IQD',
      capacity: 5,
      seatsRemaining: seatsRemaining,
      sessions: const [],
      isPublished: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  tearDown(() {
    CourseDependencies.setRepositoryOverride(null);
  });

  testWidgets('shows an empty state when no courses are published', (
    tester,
  ) async {
    CourseDependencies.setRepositoryOverride(_FakeCourseRepository());

    await tester.pumpWidget(wrapWithMaterial(const CoursesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد دورات متاحة حالياً'), findsOneWidget);
  });

  testWidgets('renders published courses with title and seat count', (
    tester,
  ) async {
    CourseDependencies.setRepositoryOverride(
      _FakeCourseRepository(
        courses: [
          buildCourse(id: 'c1', title: 'Wedding Photography Basics'),
        ],
      ),
    );

    await tester.pumpWidget(wrapWithMaterial(const CoursesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Wedding Photography Basics'), findsOneWidget);
    expect(find.textContaining('5 مقاعد'), findsOneWidget);
  });

  testWidgets('shows a full-course chip when seatsRemaining is zero', (
    tester,
  ) async {
    CourseDependencies.setRepositoryOverride(
      _FakeCourseRepository(
        courses: [
          buildCourse(id: 'c1', title: 'Full Course', seatsRemaining: 0),
        ],
      ),
    );

    await tester.pumpWidget(wrapWithMaterial(const CoursesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('مكتملة'), findsOneWidget);
  });

  testWidgets('shows an error message when loading fails', (tester) async {
    CourseDependencies.setRepositoryOverride(
      _FakeCourseRepository(shouldFail: true),
    );

    await tester.pumpWidget(wrapWithMaterial(const CoursesListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('حدث خطأ في تحميل الدورات'), findsOneWidget);
  });
}
