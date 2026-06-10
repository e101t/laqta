import 'package:flutter/foundation.dart';

class VideoVisibilityState {
  const VideoVisibilityState({
    required this.videoId,
    required this.visibleFraction,
    required this.shouldPlay,
  });

  final String videoId;
  final double visibleFraction;
  final bool shouldPlay;
}

class VideoVisibilityController extends ChangeNotifier {
  final Map<String, double> _visibleFractions = <String, double>{};
  final Map<String, Duration> _positions = <String, Duration>{};

  String? _activeVideoId;

  String? get activeVideoId => _activeVideoId;

  void updateVisibility(String videoId, double visibleFraction) {
    _visibleFractions[videoId] = visibleFraction.clamp(0, 1).toDouble();
    final best = _visibleFractions.entries
        .where((entry) => entry.value >= .6)
        .fold<MapEntry<String, double>?>(null, (current, entry) {
          if (current == null || entry.value > current.value) return entry;
          return current;
        });
    final next = best?.key;
    if (next != _activeVideoId) {
      _activeVideoId = next;
      notifyListeners();
    }
  }

  bool shouldPlay(String videoId) => _activeVideoId == videoId;

  void rememberPosition(String videoId, Duration position) {
    _positions[videoId] = position;
  }

  Duration rememberedPosition(String videoId) {
    return _positions[videoId] ?? Duration.zero;
  }

  void remove(String videoId) {
    _visibleFractions.remove(videoId);
    _positions.remove(videoId);
    if (_activeVideoId == videoId) {
      _activeVideoId = null;
      notifyListeners();
    }
  }
}
