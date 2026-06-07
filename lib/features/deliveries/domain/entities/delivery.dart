class Delivery {
  final String id;
  final String bookingId;
  final String photographerId;
  final String customerId;
  final String status;
  final List<String> photoMediaIds;
  final List<String> videoMediaIds;
  final List<String> otherMediaIds;
  final List<String> photoUrls;
  final List<String> videoUrls;
  final List<String> otherUrls;
  final String? note;
  final String? revisionNote;
  final int revisionCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Delivery({
    required this.id,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    required this.status,
    this.photoMediaIds = const [],
    this.videoMediaIds = const [],
    this.otherMediaIds = const [],
    required this.photoUrls,
    required this.videoUrls,
    required this.otherUrls,
    this.note,
    this.revisionNote,
    required this.revisionCount,
    required this.createdAt,
    required this.updatedAt,
  });

  Delivery copyWith({
    String? status,
    List<String>? photoMediaIds,
    List<String>? videoMediaIds,
    List<String>? otherMediaIds,
    List<String>? photoUrls,
    List<String>? videoUrls,
    List<String>? otherUrls,
    String? note,
    String? revisionNote,
    int? revisionCount,
    DateTime? updatedAt,
  }) {
    return Delivery(
      id: id,
      bookingId: bookingId,
      photographerId: photographerId,
      customerId: customerId,
      status: status ?? this.status,
      photoMediaIds: photoMediaIds ?? this.photoMediaIds,
      videoMediaIds: videoMediaIds ?? this.videoMediaIds,
      otherMediaIds: otherMediaIds ?? this.otherMediaIds,
      photoUrls: photoUrls ?? this.photoUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      otherUrls: otherUrls ?? this.otherUrls,
      note: note ?? this.note,
      revisionNote: revisionNote ?? this.revisionNote,
      revisionCount: revisionCount ?? this.revisionCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
