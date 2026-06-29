import 'package:laqta/features/courses/data/dtos/course_enrollment_dto.dart';
import 'package:laqta/features/courses/domain/entities/course_enrollment.dart';

class CourseEnrollmentMapper {
  static CourseEnrollment toDomain(CourseEnrollmentDto dto) {
    return CourseEnrollment(
      id: dto.id,
      courseId: dto.courseId,
      photographerId: dto.photographerId,
      customerId: dto.customerId,
      payment: CourseEnrollmentPayment(
        status: dto.payment.status,
        intentId: dto.payment.intentId,
        amount: dto.payment.amount,
        paidAt: dto.payment.paidAt,
      ),
      status: dto.status,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
