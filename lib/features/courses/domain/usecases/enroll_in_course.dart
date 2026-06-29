import 'package:laqta/core/domain/result/result.dart';
import '../repositories/course_repository.dart';

class EnrollInCourse {
  final CourseRepository _repository;

  const EnrollInCourse(this._repository);

  Future<Result<String>> call(String courseId) {
    return _repository.enrollInCourse(courseId);
  }
}
