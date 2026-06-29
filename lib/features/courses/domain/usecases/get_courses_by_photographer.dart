import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class GetCoursesByPhotographer {
  final CourseRepository _repository;

  const GetCoursesByPhotographer(this._repository);

  Future<Result<List<Course>>> call(String photographerId) {
    return _repository.getCoursesByPhotographer(photographerId);
  }
}
