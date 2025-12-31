// Story Highlights - Permanent story albums

class Timestamp {
  final DateTime dateTime;
  Timestamp.fromDate(this.dateTime);
  DateTime toDate() => dateTime;
}

class DocumentSnapshot {
  final String id;
  final Map<String, dynamic>? _data;
  DocumentSnapshot(this.id, this._data);
  Map<String, dynamic>? data() => _data;
}

class StoryHighlight {
  final String highlightId;
  final String photographerId;
  final String title;
  final String coverImageUrl;
  final List<String> storyIds; // List of saved story IDs
  final DateTime createdAt;
  final DateTime updatedAt;
  final int storiesCount;

  StoryHighlight({
    required this.highlightId,
    required this.photographerId,
    required this.title,
    required this.coverImageUrl,
    required this.storyIds,
    required this.createdAt,
    required this.updatedAt,
    required this.storiesCount,
  });

  factory StoryHighlight.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryHighlight(
      highlightId: doc.id,
      photographerId: data['photographerId'] ?? '',
      title: data['title'] ?? '',
      coverImageUrl: data['coverImageUrl'] ?? '',
      storyIds: List<String>.from(data['storyIds'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storiesCount: (data['storyIds'] as List?)?.length ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'photographerId': photographerId,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'storyIds': storyIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'storiesCount': storiesCount,
    };
  }
}
