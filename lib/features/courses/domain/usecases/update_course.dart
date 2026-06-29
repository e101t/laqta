import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class UpdateCourse {
  final CourseRepository _repository;

  const UpdateCourse(this._repository);

  Future<Result<void>> call(Course course) {
    return _repository.updateCourse(course);
  }
}
