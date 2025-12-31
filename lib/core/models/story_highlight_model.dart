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
    final data = _safeData(doc.data());
    final storyIds = _readStringList(data['storyIds']);
    return StoryHighlight(
      highlightId: doc.id,
      photographerId: _readString(data['photographerId']),
      title: _readString(data['title']),
      coverImageUrl: _readString(data['coverImageUrl']),
      storyIds: storyIds,
      createdAt: _readDate(data['createdAt']) ?? DateTime.now(),
      updatedAt: _readDate(data['updatedAt']) ?? DateTime.now(),
      storiesCount: storyIds.length,
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

Map<String, dynamic> _safeData(Map<String, dynamic>? data) {
  return data ?? <String, dynamic>{};
}

String _readString(dynamic value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

List<String> _readStringList(dynamic value) {
  if (value is List) {
    return value.whereType<String>().toList();
  }
  return const [];
}

DateTime? _readDate(dynamic value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is num) {
    return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  }
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return parsed;
    final millis = int.tryParse(value);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }
  return null;
}
