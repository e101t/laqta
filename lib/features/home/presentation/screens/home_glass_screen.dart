import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/design_system/laqta_tokens.dart';
import 'package:luqta/ui/chips_filter.dart';
import 'package:luqta/ui/glass_card.dart';
import 'package:luqta/ui/laqta_app_bar.dart';
import 'package:luqta/ui/laqta_bottom_nav.dart';
import 'package:luqta/ui/photographer_card.dart';
import 'package:luqta/ui/post_card.dart';
import 'package:luqta/ui/story_bubble.dart';
import 'package:luqta/ui/states.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/home/domain/entities/home_photographer.dart';
import 'package:luqta/features/home/domain/entities/home_story.dart';
import 'package:luqta/features/home/home_dependencies.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/reels_dependencies.dart';

class HomeGlassScreen extends StatefulWidget {
  final bool showBottomNav;

  const HomeGlassScreen({super.key, this.showBottomNav = true});

  @override
  State<HomeGlassScreen> createState() => _HomeGlassScreenState();
}

class _HomeGlassScreenState extends State<HomeGlassScreen> {
  int _currentIndex = 0;
  int _filterIndex = 0;
  String _currentUserId = '';

  final List<HomeStory> _stories = [];
  final List<ReelModel> _reels = [];
  final List<HomePhotographer> _discover = [];

  bool _isLoadingStories = true;
  bool _isLoadingReels = true;
  bool _isLoadingDiscover = true;

  String? _storiesError;
  String? _reelsError;
  String? _discoverError;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadAll();
  }

  Future<void> _loadCurrentUser() async {
    final result = await AuthDependencies.getCurrentUser().call();
    if (!mounted) return;
    setState(() {
      _currentUserId = result.valueOrNull?.id ?? '';
    });
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadStories(), _loadReels(), _loadDiscover()]);
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoadingStories = true;
      _storiesError = null;
    });

    try {
      final result = await HomeDependencies.getActiveStories().call();
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load stories',
        );
      }
      final stories = result.valueOrNull ?? <HomeStory>[];
      if (!mounted) return;
      setState(() {
        _stories
          ..clear()
          ..addAll(stories);
        _isLoadingStories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingStories = false;
        _storiesError = 'Failed to load stories';
      });
    }
  }

  Future<void> _loadReels() async {
    setState(() {
      _isLoadingReels = true;
      _reelsError = null;
    });

    try {
      final result = await ReelsDependencies.getReels().call();
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load reels',
        );
      }
      final reels = (result.valueOrNull ?? <ReelModel>[]).take(20).toList();
      if (!mounted) return;
      setState(() {
        _reels
          ..clear()
          ..addAll(reels);
        _isLoadingReels = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingReels = false;
        _reelsError = 'Failed to load reels';
      });
    }
  }

  Future<void> _loadDiscover() async {
    setState(() {
      _isLoadingDiscover = true;
      _discoverError = null;
    });

    try {
      final result = await HomeDependencies.getHomePhotographers().call(
        limit: 12,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load photographers',
        );
      }
      final profiles = result.valueOrNull ?? <HomePhotographer>[];
      if (!mounted) return;
      setState(() {
        _discover
          ..clear()
          ..addAll(profiles);
        _isLoadingDiscover = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingDiscover = false;
        _discoverError = 'Failed to load photographers';
      });
    }
  }

  List<HomeStory> _uniqueStories() {
    final seen = <String>{};
    final result = <HomeStory>[];
    for (final story in _stories) {
      if (seen.add(story.photographerId)) {
        result.add(story);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: LaqtaColors.canvas,
      appBar: LAQTAAppBar(
        title: localizations.appName,
        subtitle: localizations.explorePhotographers,
        onNotificationsTap: () => AppRouter.goToNotifications(context),
      ),
      bottomNavigationBar: widget.showBottomNav
          ? LAQTABottomNav(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildStoriesSection(localizations),
            const SizedBox(height: 16),
            Text(
              '??????? ???????',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ChipsFilter(
              labels: const ['????', '?????? ???????', '??????', '???? ?????'],
              selectedIndex: _filterIndex,
              onSelected: (index) => setState(() => _filterIndex = index),
            ),
            const SizedBox(height: 20),
            Text('?????????', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _buildFeedSection(localizations),
            const SizedBox(height: 8),
            Text('??????', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            _buildDiscoverSection(localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesSection(AppLocalizations localizations) {
    if (_isLoadingStories) {
      return GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return const LoadingSkeleton(height: 60, width: 60);
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: 5,
          ),
        ),
      );
    }

    if (_storiesError != null) {
      return ErrorState(
        title: localizations.error,
        message: _storiesError!,
        onRetry: _loadStories,
      );
    }

    final stories = _uniqueStories();
    if (stories.isEmpty) {
      return EmptyState(
        title: localizations.noData,
        message: localizations.noResults,
      );
    }

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: SizedBox(
        height: 90,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final story = stories[index];
            final bubbleImage = story.photographerPhotoUrl?.isNotEmpty == true
                ? story.photographerPhotoUrl
                : story.imageUrl;
            return StoryBubble(
              title: story.photographerName,
              imageUrl: bubbleImage?.isNotEmpty == true ? bubbleImage : null,
              isViewed: _currentUserId.isNotEmpty
                  ? story.hasUserViewed(_currentUserId)
                  : false,
              onTap: () => AppRouter.goToPhotographerProfile(
                context,
                story.photographerId,
              ),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemCount: stories.length,
        ),
      ),
    );
  }

  Widget _buildFeedSection(AppLocalizations localizations) {
    if (_isLoadingReels) {
      return Column(
        children: const [
          LoadingSkeleton(height: 190),
          SizedBox(height: 16),
          LoadingSkeleton(height: 190),
        ],
      );
    }

    if (_reelsError != null) {
      return ErrorState(
        title: localizations.error,
        message: _reelsError!,
        onRetry: _loadReels,
      );
    }

    if (_reels.isEmpty) {
      return EmptyState(
        title: localizations.noData,
        message: localizations.noResults,
      );
    }

    return Column(
      children: _reels.take(8).map((reel) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            authorName: reel.photographerName,
            authorAvatarUrl: reel.photographerPhotoUrl,
            imageUrl: reel.thumbnailUrl ?? '',
            caption: reel.caption,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiscoverSection(AppLocalizations localizations) {
    if (_isLoadingDiscover) {
      return SizedBox(
        height: 120,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return const SizedBox(
              width: 240,
              child: LoadingSkeleton(height: 120),
            );
          },
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemCount: 3,
        ),
      );
    }

    if (_discoverError != null) {
      return ErrorState(
        title: localizations.error,
        message: _discoverError!,
        onRetry: _loadDiscover,
      );
    }

    if (_discover.isEmpty) {
      return EmptyState(
        title: localizations.noPhotographers,
        message: localizations.noResults,
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = _discover[index];
          return SizedBox(
            width: 240,
            child: PhotographerCard(
              name: item.displayName,
              location: item.primaryGovernorate,
              rating: item.rating,
              price: item.basePrice.toStringAsFixed(0),
              avatarUrl: item.photoUrl,
              onTap: () => AppRouter.goToPhotographerProfile(context, item.id),
            ),
          );
        },
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemCount: _discover.length,
      ),
    );
  }
}
