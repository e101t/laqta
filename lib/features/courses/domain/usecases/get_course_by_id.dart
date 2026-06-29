import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCourseById {
  final CourseRepository _repository;

  const GetCourseById(this._repository);

  Future<Result<Course>> call(String courseId) {
    return _repository.getCourseById(courseId);
  }
}
