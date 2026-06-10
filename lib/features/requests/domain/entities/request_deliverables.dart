class RequestDeliverables {
  final int? photosCount;
  final int? videoMinutes;
  final bool includesEditing;
  final bool includesVideo;
  final String? notes;

  const RequestDeliverables({
    this.photosCount,
    this.videoMinutes,
    this.includesEditing = false,
    this.includesVideo = false,
    this.notes,
  });

  RequestDeliverables copyWith({
    int? photosCount,
    int? videoMinutes,
    bool? includesEditing,
    bool? includesVideo,
    String? notes,
  }) {
    return RequestDeliverables(
      photosCount: photosCount ?? this.photosCount,
      videoMinutes: videoMinutes ?? this.videoMinutes,
      includesEditing: includesEditing ?? this.includesEditing,
      includesVideo: includesVideo ?? this.includesVideo,
      notes: notes ?? this.notes,
    );
  }
}
