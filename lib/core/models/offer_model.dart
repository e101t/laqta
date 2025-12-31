import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:luqta/core/utils/firestore_parsers.dart';

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
    final data = firestoreMap(doc.data());
    return OfferModel(
      id: doc.id,
      photographerId: readString(data, 'photographerId'),
      title: readString(data, 'title'),
      description: readNullableString(data, 'desc'),
      discountPct: readInt(data, 'discountPct'),
      validUntil: readDateTime(data, 'validUntil'),
      createdAt: readDateTime(data, 'createdAt'),
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
