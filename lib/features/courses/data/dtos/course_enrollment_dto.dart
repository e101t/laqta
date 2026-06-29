class CourseEnrollmentDto {
  final String id;
  final String courseId;
  final String photographerId;
  final String customerId;
  final CourseEnrollmentPaymentDto payment;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseEnrollmentDto({
    required this.id,
    required this.courseId,
    required this.photographerId,
    required this.customerId,
    required this.payment,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CourseEnrollmentDto.fromJson(Map<String, dynamic> json) {
    final paymentMap = json['payment'];

    return CourseEnrollmentDto(
      id: _readString(json, 'id'),
      courseId: _readString(json, 'courseId'),
      photographerId: _readString(json, 'photographerId'),
      customerId: _readString(json, 'customerId'),
      payment: paymentMap is Map
          ? CourseEnrollmentPaymentDto.fromMap(
              Map<String, dynamic>.from(paymentMap),
            )
          : const CourseEnrollmentPaymentDto(),
      status: _readString(json, 'status', fallback: 'pending_payment'),
      createdAt: _readDateTime(json['createdAt']),
      updatedAt: _readDateTime(json['updatedAt']),
    );
  }

  static String _readString(
    Map<String, dynamic> data,
    String key, {
    String fallback = '',
  }) {
    final value = data[key];
    return value is String ? value : fallback;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

class CourseEnrollmentPaymentDto {
  final String status;
  final String? intentId;
  final double? amount;
  final DateTime? paidAt;

  const CourseEnrollmentPaymentDto({
    this.status = 'pending',
    this.intentId,
    this.amount,
    this.paidAt,
  });

  factory CourseEnrollmentPaymentDto.fromMap(Map<String, dynamic> map) {
    final amount = map['amount'];
    final paidAt = map['paidAt'];
    final intentId = map['intentId'];
    return CourseEnrollmentPaymentDto(
      status: map['status'] is String ? map['status'] as String : 'pending',
      intentId: intentId is String ? intentId : null,
      amount: amount is num ? amount.toDouble() : null,
      paidAt: paidAt is String ? DateTime.tryParse(paidAt) : null,
    );
  }
}
