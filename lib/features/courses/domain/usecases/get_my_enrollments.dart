import 'package:laqta/core/domain/result/result.dart';
import '../entities/course_enrollment.dart';
import '../repositories/course_repository.dart';

class GetMyEnrollments {
  final CourseRepository _repository;

  const GetMyEnrollments(this._repository);

  Future<Result<List<CourseEnrollment>>> call(String customerId) {
    return _repository.getMyEnrollments(customerId);
  }
}
