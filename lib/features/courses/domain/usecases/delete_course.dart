import 'package:laqta/core/domain/result/result.dart';
import '../repositories/course_repository.dart';

class DeleteCourse {
  final CourseRepository _repository;

  const DeleteCourse(this._repository);

  Future<Result<void>> call(String courseId) {
    return _repository.deleteCourse(courseId);
  }
}
