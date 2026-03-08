import 'request_deliverables.dart';

class PhotoRequest {
  final String id;
  final String clientId;
  final String type;
  final String date;
  final String time;
  final String governorate;
  final String? address;
  final double? budgetMin;
  final double? budgetMax;
  final int durationHours;
  final String? style;
  final RequestDeliverables deliverables;
  final String? notes;
  final List<String> referenceImages;
  final String status;
  final int offersCount;
  final String? selectedOfferId;
  final String? selectedPhotographerId;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  const PhotoRequest({
    required this.id,
    required this.clientId,
    required this.type,
    required this.date,
    required this.time,
    required this.governorate,
    this.address,
    this.budgetMin,
    this.budgetMax,
    required this.durationHours,
    this.style,
    required this.deliverables,
    this.notes,
    required this.referenceImages,
    required this.status,
    required this.offersCount,
    this.selectedOfferId,
    this.selectedPhotographerId,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  PhotoRequest copyWith({
    String? status,
    int? offersCount,
    String? selectedOfferId,
    String? selectedPhotographerId,
    DateTime? updatedAt,
    double? latitude,
    double? longitude,
    String? locationLabel,
  }) {
    return PhotoRequest(
      id: id,
      clientId: clientId,
      type: type,
      date: date,
      time: time,
      governorate: governorate,
      address: address,
      budgetMin: budgetMin,
      budgetMax: budgetMax,
      durationHours: durationHours,
      style: style,
      deliverables: deliverables,
      notes: notes,
      referenceImages: referenceImages,
      status: status ?? this.status,
      offersCount: offersCount ?? this.offersCount,
      selectedOfferId: selectedOfferId ?? this.selectedOfferId,
      selectedPhotographerId:
          selectedPhotographerId ?? this.selectedPhotographerId,
      expiresAt: expiresAt,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
    );
  }
}
