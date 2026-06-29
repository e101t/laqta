import 'package:laqta/core/domain/result/result.dart';
import '../repositories/course_repository.dart';

class CreateEnrollmentPaymentIntent {
  final CourseRepository _repository;

  const CreateEnrollmentPaymentIntent(this._repository);

  Future<Result<CourseEnrollmentPaymentIntent>> call({
    required String enrollmentId,
    required double amount,
    required String currency,
  }) {
    return _repository.createEnrollmentPaymentIntent(
      enrollmentId: enrollmentId,
      amount: amount,
      currency: currency,
    );
  }
}
