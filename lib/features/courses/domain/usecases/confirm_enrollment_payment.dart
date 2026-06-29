import 'package:laqta/core/domain/result/result.dart';
import '../repositories/course_repository.dart';

class ConfirmEnrollmentPayment {
  final CourseRepository _repository;

  const ConfirmEnrollmentPayment(this._repository);

  Future<Result<void>> call({
    required String enrollmentId,
    required String paymentIntentId,
    required double amount,
  }) {
    return _repository.confirmEnrollmentPayment(
      enrollmentId: enrollmentId,
      paymentIntentId: paymentIntentId,
      amount: amount,
    );
  }
}
