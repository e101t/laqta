class CourseEnrollment {
  final String id;
  final String courseId;
  final String photographerId;
  final String customerId;
  final CourseEnrollmentPayment payment;
  final String status; // 'pending_payment' | 'confirmed' | 'canceled'
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseEnrollment({
    required this.id,
    required this.courseId,
    required this.photographerId,
    required this.customerId,
    required this.payment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isConfirmed => status == 'confirmed';
}

class CourseEnrollmentPayment {
  final String status; // pending, succeeded, failed, refunded
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  const CourseEnrollmentPayment({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });
}
