import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class CreateCourse {
  final CourseRepository _repository;

  const CreateCourse(this._repository);

  Future<Result<String>> call(Course course) {
    return _repository.createCourse(course);
  }
}
