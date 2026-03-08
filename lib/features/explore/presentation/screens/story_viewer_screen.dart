import 'package:flutter/material.dart';

import 'package:luqta/app/router/app_router.dart';
import 'package:luqta/core/models/story_model.dart';
import 'package:luqta/core/services/story_service.dart';
import 'package:luqta/core/utils/image_provider.dart';

class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final String currentUserId;
  final bool isCustomer;
  final void Function(StoryModel story) onCreateRequest;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
    required this.currentUserId,
    required this.isCustomer,
    required this.onCreateRequest,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final PageController _controller;
  final StoryService _storyService = StoryService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
    _recordView(widget.stories[_currentIndex]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _recordView(StoryModel story) async {
    if (widget.currentUserId.isEmpty) return;
    await _storyService.recordStoryView(
      storyId: story.storyId,
      userId: widget.currentUserId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: widget.stories.length,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
                _recordView(widget.stories[index]);
              },
              itemBuilder: (context, index) {
                final story = widget.stories[index];
                final provider = resolveImageProvider(story.imageUrl);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    if (provider != null)
                      Image(
                        image: provider,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white,
                            ),
                          );
                        },
                      )
                    else
                      const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                        ),
                      ),
                    if (story.caption != null && story.caption!.isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 110,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            story.caption!,
                            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.stories[_currentIndex].photographerName,
                      style: textTheme.bodyLarge?.copyWith(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    widget.stories[_currentIndex].getTimeAgo(),
                    style: textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () => AppRouter.goToPhotographerProfile(
                        context,
                        widget.stories[_currentIndex].photographerId,
                      ),
                      child: const Text('عرض المصور'),
                    ),
                  ),
                  if (widget.isCustomer) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () =>
                            widget.onCreateRequest(widget.stories[_currentIndex]),
                        child: const Text('طلب نفس الأسلوب'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
