import 'package:flutter/foundation.dart';
import 'package:luqta/features/downloads/domain/entities/download_link_entity.dart';
import 'package:luqta/features/downloads/domain/usecases/download_usecases.dart';

/// Download State Management
class DownloadProvider extends ChangeNotifier {
  final GenerateDownloadLinksUseCase _generateLinksUseCase;
  final ExtendDownloadLinkUseCase _extendLinkUseCase;
  final GetDownloadLinksUseCase _getLinksUseCase;

  DownloadProvider({
    required GenerateDownloadLinksUseCase generateLinksUseCase,
    required ExtendDownloadLinkUseCase extendLinkUseCase,
    required GetDownloadLinksUseCase getLinksUseCase,
  }) : _generateLinksUseCase = generateLinksUseCase,
       _extendLinkUseCase = extendLinkUseCase,
       _getLinksUseCase = getLinksUseCase;

  DownloadLinkBatch? _batch;
  bool _loading = false;
  String? _error;

  DownloadLinkBatch? get batch => _batch;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> generateLinks(
    String photographerId,
    String bookingId,
    String customerId,
    List<String> fileIds,
  ) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _batch = await _generateLinksUseCase(
        photographerId,
        bookingId,
        customerId,
        fileIds,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
      _batch = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadLinks(String bookingId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _batch = await _getLinksUseCase(bookingId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _batch = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> extendLink(String linkId) async {
    try {
      final extended = await _extendLinkUseCase(linkId);
      if (_batch != null) {
        final index = _batch!.links.indexWhere((l) => l.linkId == linkId);
        if (index != -1) {
          _batch!.links[index] = extended;
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}
