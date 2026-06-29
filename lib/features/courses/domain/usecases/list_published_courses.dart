import 'package:laqta/core/domain/result/result.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

class ListPublishedCourses {
  final CourseRepository _repository;

  const ListPublishedCourses(this._repository);

  Future<Result<List<Course>>> call({String? specialty}) {
    return _repository.listPublishedCourses(specialty: specialty);
  }
}
