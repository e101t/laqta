import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String photographerId;
  final String title;
  final String? description;
  final int discountPct; // percentage
  final DateTime validUntil;
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.photographerId,
    required this.title,
    this.description,
    required this.discountPct,
    required this.validUntil,
    required this.createdAt,
  });

  factory OfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id: doc.id,
      photographerId: data['photographerId'] ?? '',
      title: data['title'] ?? '',
      description: data['desc'],
      discountPct: data['discountPct'] ?? 0,
      validUntil:
          (data['validUntil'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photographerId': photographerId,
      'title': title,
      'desc': description,
      'discountPct': discountPct,
      'validUntil': Timestamp.fromDate(validUntil),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  bool get isActive => DateTime.now().isBefore(validUntil);

  double applyDiscount(double originalPrice) {
    return originalPrice * (1 - discountPct / 100);
  }
}
