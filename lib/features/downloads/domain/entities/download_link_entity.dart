// Temporary Download Links System
// Photos expire after 30 days and can be extended once.

class DownloadLinkEntity {
  final String linkId;
  final String bookingId;
  final String photographerId;
  final String customerId;
  final String fileUrl;
  final String temporaryUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int extensionsUsed;
  final int maxExtensions;
  final bool isExpired;
  final int downloadCount;
  final int maxDownloads;

  DownloadLinkEntity({
    required this.linkId,
    required this.bookingId,
    required this.photographerId,
    required this.customerId,
    required this.fileUrl,
    required this.temporaryUrl,
    required this.createdAt,
    required this.expiresAt,
    this.extensionsUsed = 0,
    this.maxExtensions = 1,
    this.isExpired = false,
    this.downloadCount = 0,
    this.maxDownloads = -1,
  });

  int get daysRemaining {
    final now = DateTime.now();
    return expiresAt.difference(now).inDays;
  }

  bool get isValid {
    final now = DateTime.now();
    final withinTime = now.isBefore(expiresAt);
    final withinDownloads = maxDownloads == -1 || downloadCount < maxDownloads;
    return withinTime && withinDownloads && !isExpired;
  }

  bool get canExtend => !isExpired && extensionsUsed < maxExtensions;

  DownloadLinkEntity copyWith({
    String? linkId,
    String? bookingId,
    String? photographerId,
    String? customerId,
    String? fileUrl,
    String? temporaryUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    int? extensionsUsed,
    int? maxExtensions,
    bool? isExpired,
    int? downloadCount,
    int? maxDownloads,
  }) {
    return DownloadLinkEntity(
      linkId: linkId ?? this.linkId,
      bookingId: bookingId ?? this.bookingId,
      photographerId: photographerId ?? this.photographerId,
      customerId: customerId ?? this.customerId,
      fileUrl: fileUrl ?? this.fileUrl,
      temporaryUrl: temporaryUrl ?? this.temporaryUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      extensionsUsed: extensionsUsed ?? this.extensionsUsed,
      maxExtensions: maxExtensions ?? this.maxExtensions,
      isExpired: isExpired ?? this.isExpired,
      downloadCount: downloadCount ?? this.downloadCount,
      maxDownloads: maxDownloads ?? this.maxDownloads,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'linkId': linkId,
      'bookingId': bookingId,
      'photographerId': photographerId,
      'customerId': customerId,
      'fileUrl': fileUrl,
      'temporaryUrl': temporaryUrl,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'extensionsUsed': extensionsUsed,
      'maxExtensions': maxExtensions,
      'isExpired': isExpired,
      'downloadCount': downloadCount,
      'maxDownloads': maxDownloads,
    };
  }

  factory DownloadLinkEntity.fromJson(Map<String, dynamic> json) {
    return DownloadLinkEntity(
      linkId: json['linkId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      photographerId: json['photographerId'] ?? '',
      customerId: json['customerId'] ?? '',
      fileUrl: json['fileUrl'] ?? '',
      temporaryUrl: json['temporaryUrl'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      expiresAt: DateTime.parse(
        json['expiresAt'] ?? DateTime.now().toIso8601String(),
      ),
      extensionsUsed: json['extensionsUsed'] ?? 0,
      maxExtensions: json['maxExtensions'] ?? 1,
      isExpired: json['isExpired'] ?? false,
      downloadCount: json['downloadCount'] ?? 0,
      maxDownloads: json['maxDownloads'] ?? -1,
    );
  }

  DownloadLinkEntity extend() {
    if (!canExtend) {
      throw StateError('Cannot extend this link');
    }
    return DownloadLinkEntity(
      linkId: linkId,
      bookingId: bookingId,
      photographerId: photographerId,
      customerId: customerId,
      fileUrl: fileUrl,
      temporaryUrl: temporaryUrl,
      createdAt: createdAt,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      extensionsUsed: extensionsUsed + 1,
      maxExtensions: maxExtensions,
      isExpired: false,
      downloadCount: downloadCount,
      maxDownloads: maxDownloads,
    );
  }

  DownloadLinkEntity recordDownload() {
    return DownloadLinkEntity(
      linkId: linkId,
      bookingId: bookingId,
      photographerId: photographerId,
      customerId: customerId,
      fileUrl: fileUrl,
      temporaryUrl: temporaryUrl,
      createdAt: createdAt,
      expiresAt: expiresAt,
      extensionsUsed: extensionsUsed,
      maxExtensions: maxExtensions,
      isExpired: isExpired,
      downloadCount: downloadCount + 1,
      maxDownloads: maxDownloads,
    );
  }

  String getStatusText() {
    if (!isValid) {
      return 'Expired';
    }
    if (daysRemaining <= 7) {
      return 'Expiring in $daysRemaining days';
    }
    return 'Active';
  }
}

class DownloadLinkBatch {
  final String batchId;
  final String bookingId;
  final List<DownloadLinkEntity> links;
  final int photoCount;
  final DateTime createdAt;
  final bool includesRaw;
  final bool includesEdited;

  DownloadLinkBatch({
    required this.batchId,
    required this.bookingId,
    required this.links,
    required this.photoCount,
    required this.createdAt,
    this.includesRaw = false,
    this.includesEdited = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'bookingId': bookingId,
      'links': links.map((l) => l.toJson()).toList(),
      'photoCount': photoCount,
      'createdAt': createdAt.toIso8601String(),
      'includesRaw': includesRaw,
      'includesEdited': includesEdited,
    };
  }

  factory DownloadLinkBatch.fromJson(Map<String, dynamic> json) {
    return DownloadLinkBatch(
      batchId: json['batchId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      links:
          (json['links'] as List?)
              ?.map(
                (l) => DownloadLinkEntity.fromJson(l as Map<String, dynamic>),
              )
              .toList() ??
          [],
      photoCount: json['photoCount'] ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      includesRaw: json['includesRaw'] ?? false,
      includesEdited: json['includesEdited'] ?? true,
    );
  }

  bool get allValid => links.every((l) => l.isValid);

  bool get anyExpiringSoon =>
      links.any((l) => l.isValid && l.daysRemaining <= 7);

  Map<String, dynamic> getSummary() {
    return {
      'totalPhotos': photoCount,
      'validLinks': links.where((l) => l.isValid).length,
      'expiredLinks': links.where((l) => !l.isValid).length,
      'canExtendCount': links.where((l) => l.canExtend).length,
      'daysRemaining': links.isNotEmpty ? links.first.daysRemaining : 0,
      'includesRaw': includesRaw,
      'includesEdited': includesEdited,
    };
  }
}

class PhotographerDeliveryConfig {
  final String photographerId;
  final int deliveryWindowDays;
  final int downloadLinkValidityDays;
  final int maxExtensions;
  final bool provideRaw;
  final bool provideEdited;
  final bool autoGenerateLinks;

  PhotographerDeliveryConfig({
    required this.photographerId,
    this.deliveryWindowDays = 7,
    this.downloadLinkValidityDays = 30,
    this.maxExtensions = 1,
    this.provideRaw = false,
    this.provideEdited = true,
    this.autoGenerateLinks = true,
  });
}
