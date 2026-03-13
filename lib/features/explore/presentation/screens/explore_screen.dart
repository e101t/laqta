import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import 'package:luqta/app/router/app_router.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/services/follow_service.dart';
import 'package:luqta/core/services/report_service.dart';
import 'package:luqta/core/utils/runtime_env.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/post_card.dart';
import 'package:luqta/core/widgets/photographer_card.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/reels/domain/entities/comment_model.dart';
import 'package:luqta/features/reels/domain/entities/reel_model.dart';
import 'package:luqta/features/reels/reels_dependencies.dart';
import 'package:luqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:luqta/features/search/domain/entities/search_result_photographer.dart';
import 'package:luqta/features/search/search_dependencies.dart';

class ExploreScreen extends StatefulWidget {
  final FollowService? followService;
  final ReportService? reportService;
  final Future<Set<String>> Function(String userId)? fetchFollowingOverride;
  final Future<void> Function({
    required String reporterId,
    required String targetId,
    required String targetType,
    required String targetOwnerId,
    required String reason,
  })?
  submitReportOverride;

  const ExploreScreen({
    super.key,
    this.followService,
    this.reportService,
    this.fetchFollowingOverride,
    this.submitReportOverride,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  FollowService? _followService;
  ReportService? _reportService;

  String _userId = '';
  String _userName = 'User';
  String? _userAvatar;
  String _userRole = AppConstants.roleCustomer;

  Set<String> _followingIds = {};

  bool _postsLoading = true;
  String? _postsError;
  List<ReelModel> _posts = [];

  bool _photographersLoading = true;
  String? _photographersError;
  List<SearchResultPhotographer> _photographers = [];

  final Set<String> _likedReels = {};
  final Map<String, DateTime> _lastLike = {};

  bool get _isCustomer => _userRole == AppConstants.roleCustomer;
  bool get _isPhotographer => _userRole == AppConstants.rolePhotographer;
  bool get _useDemoContent =>
      AppConstants.enableDemoContent && kDebugMode && !isFlutterTestEnv();

  @override
  void initState() {
    super.initState();
    _followService = widget.followService;
    _reportService = widget.reportService;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_initialize());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initialize() async {
    await Future.wait<void>([_loadUser(), _loadPosts(), _loadPhotographers()]);
  }

  Future<void> _loadUser() async {
    try {
      final authResult = await AuthDependencies.getCurrentUser().call();
      final userId = authResult.valueOrNull?.id ?? '';
      if (userId.isEmpty) {
        return;
      }
      _userId = userId;
      final profileResult = await ProfileDependencies.getUserProfile().call(
        userId: userId,
      );
      final profile = profileResult.valueOrNull;
      if (profile != null) {
        _userName = profile.name;
        _userAvatar = profile.photoUrl;
        _userRole = profile.role;
      }
      if (widget.fetchFollowingOverride != null) {
        _followingIds = await widget.fetchFollowingOverride!(userId);
      } else {
        final service = _followService ?? FollowService();
        _followService = service;
        _followingIds = await service.fetchFollowing(userId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Explore init error: $e');
      }
    } finally {
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadPosts() async {
    setState(() {
      _postsLoading = true;
      _postsError = null;
    });
    try {
      final result = await ReelsDependencies.getReels().call();
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Failed to load');
      }
      if (!mounted) return;
      setState(() {
        final data = result.valueOrNull ?? [];
        _posts = data.isEmpty && _useDemoContent ? _buildDemoPosts() : data;
        _postsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_useDemoContent) {
        setState(() {
          _posts = _buildDemoPosts();
          _postsLoading = false;
          _postsError = null;
        });
      } else {
        setState(() {
          _postsLoading = false;
          _postsError = 'Failed to load posts';
        });
      }
    }
  }

  Future<void> _loadPhotographers() async {
    setState(() {
      _photographersLoading = true;
      _photographersError = null;
    });
    try {
      final result = await SearchDependencies.searchPhotographers().call(
        query: '',
      );
      if (!result.isSuccess) {
        throw StateError(result.failureOrNull?.message ?? 'Failed to load');
      }
      final data = result.valueOrNull ?? [];
      if (!mounted) return;
      setState(() {
        final list = data.isEmpty && _useDemoContent
            ? _buildDemoPhotographers()
            : data;
        _photographers = list.take(12).toList();
        _photographersLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_useDemoContent) {
        setState(() {
          _photographers = _buildDemoPhotographers().take(12).toList();
          _photographersLoading = false;
          _photographersError = null;
        });
      } else {
        setState(() {
          _photographersLoading = false;
          _photographersError = 'Failed to load photographers';
        });
      }
    }
  }

  List<SearchResultPhotographer> _buildDemoPhotographers() {
    return const [
      SearchResultPhotographer(
        id: 'demo_ph_1',
        name: 'Ù…Ø±ÙˆØ© Ø§Ù„Ø­Ø±Ø¨ÙŠ',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ø¨ÙˆØ±ØªØ±ÙŠÙ‡', 'Ù…ÙˆØ¶Ø©'],
        rating: 4.8,
        reviewCount: 124,
        startingPrice: 120000,
        governorate: 'Ø¨ØºØ¯Ø§Ø¯',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_2',
        name: 'Ø³ÙŠÙ Ø§Ù„ÙƒØ¹Ø¨ÙŠ',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ù…Ù†Ø§Ø³Ø¨Ø§Øª', 'Ø²ÙØ§Ù'],
        rating: 4.6,
        reviewCount: 89,
        startingPrice: 150000,
        governorate: 'Ø§Ù„Ø¨ØµØ±Ø©',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_3',
        name: 'Ù†ÙˆØ± Ø§Ù„Ù‡Ø§Ø¯ÙŠ',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ù…Ù†ØªØ¬Ø§Øª', 'ØªØ¬Ø§Ø±ÙŠ'],
        rating: 4.9,
        reviewCount: 156,
        startingPrice: 90000,
        governorate: 'Ø£Ø±Ø¨ÙŠÙ„',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_4',
        name: 'Ø±Ù†ÙŠÙ… Ø§Ù„Ø¨ØºØ¯Ø§Ø¯ÙŠ',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ø¬Ù„Ø³Ø§Øª Ø¹Ø§Ø¦Ù„ÙŠØ©', 'Ø£Ø³Ù„ÙˆØ¨ Ø·Ø¨ÙŠØ¹ÙŠ'],
        rating: 4.7,
        reviewCount: 72,
        startingPrice: 105000,
        governorate: 'ÙƒØ±Ø¨Ù„Ø§Ø¡',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_5',
        name: 'Ø¹Ù…Ø± Ø§Ù„Ø³Ø¹Ø¯ÙŠ',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ø·Ø¹Ø§Ù…', 'Ø¥Ø¹Ù„Ø§Ù†ÙŠ'],
        rating: 4.5,
        reviewCount: 58,
        startingPrice: 98000,
        governorate: 'Ø§Ù„Ù†Ø¬Ù',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_6',
        name: 'Ø²Ù‡Ø±Ø§Ø¡ Ø³Ø§Ù„Ù…',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ø£Ø·ÙØ§Ù„', 'Ù…ÙˆØ§Ù„ÙŠØ¯'],
        rating: 4.8,
        reviewCount: 143,
        startingPrice: 115000,
        governorate: 'Ù†ÙŠÙ†ÙˆÙ‰',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_7',
        name: 'Ø¹Ù„ÙŠ Ø´Ø§ÙƒØ±',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ù…Ø¹Ù…Ø§Ø±ÙŠ', 'Ø¹Ù‚Ø§Ø±Ø§Øª'],
        rating: 4.6,
        reviewCount: 81,
        startingPrice: 130000,
        governorate: 'Ø§Ù„Ø³Ù„ÙŠÙ…Ø§Ù†ÙŠØ©',
      ),
      SearchResultPhotographer(
        id: 'demo_ph_8',
        name: 'Ù‡Ø¯Ù‰ Ø¬Ø§Ø¨Ø±',
        image: 'assets/images/placeholder.jpg',
        specialties: ['Ø£Ø²ÙŠØ§Ø¡', 'ØªØ­Ø±ÙŠØ±ÙŠ'],
        rating: 4.9,
        reviewCount: 167,
        startingPrice: 160000,
        governorate: 'Ø¨Ø§Ø¨Ù„',
      ),
    ];
  }

  List<ReelModel> _buildDemoPosts() {
    final now = DateTime.now();
    return [
      ReelModel(
        reelId: 'demo_reel_1',
        photographerId: 'demo_ph_1',
        photographerName: 'Ù…Ø±ÙˆØ© Ø§Ù„Ø­Ø±Ø¨ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_auth.png',
        thumbnailUrl: 'assets/images/hero_auth.png',
        caption:
            'Ø¥Ø¶Ø§Ø¡Ø© Ø¯Ø§ÙØ¦Ø© ÙˆÙ„Ù‚Ø·Ø© Ù‚Ø±ÙŠØ¨Ø© ØªÙØ¨Ø±Ø² Ø§Ù„ØªÙØ§ØµÙŠÙ„.',
        tags: const ['portrait', 'golden'],
        views: 1240,
        likes: 320,
        comments: 28,
        shares: 12,
        createdAt: now.subtract(const Duration(days: 1)),
        isVerified: true,
      ),
      ReelModel(
        reelId: 'demo_reel_2',
        photographerId: 'demo_ph_2',
        photographerName: 'Ø³ÙŠÙ Ø§Ù„ÙƒØ¹Ø¨ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_role.png',
        thumbnailUrl: 'assets/images/hero_role.png',
        caption: 'Ù…Ù†Ø§Ø³Ø¨Ø§Øª Ø¨Ø£Ø³Ù„ÙˆØ¨ Ø³ÙŠÙ†Ù…Ø§Ø¦ÙŠ Ù…ØªÙˆØ§Ø²Ù†.',
        tags: const ['event', 'cinematic'],
        views: 980,
        likes: 210,
        comments: 16,
        shares: 7,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      ReelModel(
        reelId: 'demo_reel_3',
        photographerId: 'demo_ph_3',
        photographerName: 'Ù†ÙˆØ± Ø§Ù„Ù‡Ø§Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_welcome.png',
        thumbnailUrl: 'assets/images/hero_welcome.png',
        caption: 'Ù…Ù†ØªØ¬Ø§Øª Ø¨Ø®Ù„ÙÙŠØ© Ù†Ø¸ÙŠÙØ© ÙˆÙ„Ù…Ø³Ø© ÙØ§Ø®Ø±Ø©.',
        tags: const ['product', 'premium'],
        views: 1560,
        likes: 402,
        comments: 35,
        shares: 19,
        createdAt: now.subtract(const Duration(hours: 20)),
      ),
      ReelModel(
        reelId: 'demo_reel_4',
        photographerId: 'demo_ph_4',
        photographerName: 'Ø±Ù†ÙŠÙ… Ø§Ù„Ø¨ØºØ¯Ø§Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_auth.png',
        thumbnailUrl: 'assets/images/hero_auth.png',
        caption: 'Ø¬Ù„Ø³Ø© Ø¹Ø§Ø¦Ù„ÙŠØ© Ø¨Ø¯ÙØ¡ Ø£Ù„ÙˆØ§Ù† Ù‡Ø§Ø¯Ø¦.',
        tags: const ['family', 'warm'],
        views: 820,
        likes: 188,
        comments: 14,
        shares: 5,
        createdAt: now.subtract(const Duration(hours: 30)),
      ),
      ReelModel(
        reelId: 'demo_reel_5',
        photographerId: 'demo_ph_5',
        photographerName: 'Ø¹Ù…Ø± Ø§Ù„Ø³Ø¹Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_role.png',
        thumbnailUrl: 'assets/images/hero_role.png',
        caption:
            'ØªØµÙˆÙŠØ± Ø·Ø¹Ø§Ù… Ø¨ØªØ¨Ø§ÙŠÙ† Ù„Ø·ÙŠÙ ÙˆØªÙØ§ØµÙŠÙ„ ÙˆØ§Ø¶Ø­Ø©.',
        tags: const ['food', 'studio'],
        views: 1340,
        likes: 276,
        comments: 22,
        shares: 11,
        createdAt: now.subtract(const Duration(hours: 12)),
      ),
      ReelModel(
        reelId: 'demo_reel_6',
        photographerId: 'demo_ph_6',
        photographerName: 'Ø²Ù‡Ø±Ø§Ø¡ Ø³Ø§Ù„Ù…',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        videoUrl: 'assets/images/hero_welcome.png',
        thumbnailUrl: 'assets/images/hero_welcome.png',
        caption: 'Ù„Ù‚Ø·Ø§Øª Ø£Ø·ÙØ§Ù„ Ø·Ø¨ÙŠØ¹ÙŠØ© Ø¨Ø¥Ø¶Ø§Ø¡Ø© Ù„Ø·ÙŠÙØ©.',
        tags: const ['kids', 'soft'],
        views: 1120,
        likes: 310,
        comments: 19,
        shares: 9,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
    ];
  }

  Future<void> _toggleFollow(String photographerId) async {
    if (_userId.isEmpty || photographerId.isEmpty) return;
    final wasFollowing = _followingIds.contains(photographerId);
    setState(() {
      if (wasFollowing) {
        _followingIds.remove(photographerId);
      } else {
        _followingIds.add(photographerId);
      }
    });

    try {
      final service = _followService ?? FollowService();
      _followService = service;
      await service.setFollowStatus(
        followerId: _userId,
        targetId: photographerId,
        follow: !wasFollowing,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (wasFollowing) {
          _followingIds.add(photographerId);
        } else {
          _followingIds.remove(photographerId);
        }
      });
      _showSnackBar('ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©');
    }
  }

  Future<void> _toggleLike(ReelModel reel) async {
    if (_userId.isEmpty) return;
    final now = DateTime.now();
    final last = _lastLike[reel.reelId];
    if (last != null && now.difference(last).inSeconds < 2) {
      return;
    }
    _lastLike[reel.reelId] = now;

    final alreadyLiked = _likedReels.contains(reel.reelId);
    setState(() {
      if (alreadyLiked) {
        _likedReels.remove(reel.reelId);
      } else {
        _likedReels.add(reel.reelId);
      }
      _posts = _posts
          .map(
            (item) => item.reelId == reel.reelId
                ? item.copyWith(likes: item.likes + (alreadyLiked ? -1 : 1))
                : item,
          )
          .toList();
    });

    final result = await ReelsDependencies.updateReelLikes().call(
      reelId: reel.reelId,
      delta: alreadyLiked ? -1 : 1,
    );
    if (!result.isSuccess) {
      if (!mounted) return;
      setState(() {
        if (alreadyLiked) {
          _likedReels.add(reel.reelId);
        } else {
          _likedReels.remove(reel.reelId);
        }
        _posts = _posts
            .map(
              (item) => item.reelId == reel.reelId
                  ? item.copyWith(likes: item.likes + (alreadyLiked ? 1 : -1))
                  : item,
            )
            .toList();
      });
      _showSnackBar('ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¥Ø¹Ø¬Ø§Ø¨');
    }
  }

  Future<void> _openComments(ReelModel reel) async {
    if (_userId.isEmpty) {
      _showSnackBar('ÙŠØ¬Ø¨ ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ø£ÙˆÙ„Ø§Ù‹');
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CommentsSheet(
        reel: reel,
        userId: _userId,
        userName: _userName,
        userAvatarUrl: _userAvatar,
        onCommentAdded: () {
          setState(() {
            _posts = _posts
                .map(
                  (item) => item.reelId == reel.reelId
                      ? item.copyWith(comments: item.comments + 1)
                      : item,
                )
                .toList();
          });
        },
      ),
    );
  }

  void _openCreateRequestFromPost(ReelModel reel) {
    if (!_isCustomer) return;
    final imageUrl = reel.thumbnailUrl ?? reel.videoUrl;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRequestScreen(
          prefillNotes:
              'Ù…Ø±Ø¬Ø¹ Ù…Ù† Ù…Ù†Ø´ÙˆØ± Ø§Ù„Ù…ØµÙˆØ± ${reel.photographerName}',
          prefillReferenceImages: imageUrl.isNotEmpty ? [imageUrl] : const [],
          prefillSelectedPhotographerId: reel.photographerId,
        ),
      ),
    );
  }

  Future<void> _shareReel(ReelModel reel) async {
    final imageUrl = reel.thumbnailUrl ?? reel.videoUrl;
    final buffer = StringBuffer()
      ..writeln('LAQTA')
      ..writeln(reel.photographerName)
      ..writeln(reel.caption);
    if (imageUrl.isNotEmpty) {
      buffer.writeln(imageUrl);
    }
    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  Future<void> _reportContent({
    required String targetId,
    required String targetType,
    required String targetOwnerId,
  }) async {
    if (_userId.isEmpty) return;
    final isArabic =
        Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
    final reasons = isArabic
        ? AppConstants.reportReasonsAr
        : AppConstants.reportReasonsEn;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...reasons.map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () => Navigator.of(context).pop(reason),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (selected == null || selected.isEmpty) return;

    try {
      if (widget.submitReportOverride != null) {
        await widget.submitReportOverride!(
          reporterId: _userId,
          targetId: targetId,
          targetType: targetType,
          targetOwnerId: targetOwnerId,
          reason: selected,
        );
      } else {
        final service = _reportService ?? ReportService();
        _reportService = service;
        await service.submitReport(
          reporterId: _userId,
          targetId: targetId,
          targetType: targetType,
          targetOwnerId: targetOwnerId,
          reason: selected,
        );
      }
      _showSnackBar('ØªÙ… Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø¨Ù„Ø§Øº');
    } catch (_) {
      _showSnackBar('ØªØ¹Ø°Ø± Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„Ø¨Ù„Ø§Øº');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        actions: [
          if (_isPhotographer)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => AppRouter.goToCreatePost(context),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadPhotographers();
          await _loadPosts();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isPhotographer) _buildCreateSection(),
            const SizedBox(height: 24),
            _buildPhotographersSection(),
            const SizedBox(height: 24),
            _buildPostsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => AppRouter.goToCreatePost(context),
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Post'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => AppRouter.goToCreateStory(context),
                icon: const Icon(Icons.bolt_outlined),
                label: const Text('Story'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPhotographersSection() {
    if (_photographersLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Photographers',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const LoadingIndicator(),
        ],
      );
    }

    if (_photographersError != null) {
      return EmptyStates.error(
        message: _photographersError,
        onRetry: _loadPhotographers,
      );
    }

    if (_photographers.isEmpty) {
      return EmptyState(
        icon: Icons.photo_camera_outlined,
        title: 'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ù…ØµÙˆØ±ÙŠÙ†',
        message: 'Ø¬Ø±Ù‘Ø¨ Ù„Ø§Ø­Ù‚Ø§Ù‹',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photographers',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ..._photographers.map((photographer) {
          final isFollowing = _followingIds.contains(photographer.id);
          final canFollow = photographer.id != _userId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                PhotographerCard(
                  name: photographer.name,
                  location: photographer.governorate,
                  rating: photographer.rating,
                  price: photographer.startingPrice.toString(),
                  avatarUrl: photographer.image.isNotEmpty
                      ? photographer.image
                      : null,
                  onTap: () => AppRouter.goToPhotographerProfile(
                    context,
                    photographer.id,
                  ),
                ),
                if (canFollow)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => _toggleFollow(photographer.id),
                      child: Text(
                        isFollowing
                            ? 'Ø¥Ù„ØºØ§Ø¡ Ø§Ù„Ù…ØªØ§Ø¨Ø¹Ø©'
                            : 'Ù…ØªØ§Ø¨Ø¹Ø©',
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPostsSection() {
    if (_postsLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posts',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          const LoadingIndicator(),
        ],
      );
    }

    if (_postsError != null) {
      return EmptyStates.error(message: _postsError, onRetry: _loadPosts);
    }

    if (_posts.isEmpty) {
      return EmptyState(
        icon: Icons.photo_library_outlined,
        title: 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ù†Ø´ÙˆØ±Ø§Øª',
        message: 'ØªØ§Ø¨Ø¹ Ø§Ù„Ù…ØµÙˆØ±ÙŠÙ† Ù„Ù…Ø´Ø§Ù‡Ø¯Ø© Ù…Ù†Ø´ÙˆØ±Ø§ØªÙ‡Ù….',
      );
    }

    final followed = _posts
        .where((p) => _followingIds.contains(p.photographerId))
        .toList();
    final suggested = _posts
        .where((p) => !_followingIds.contains(p.photographerId))
        .toList();

    final sections = <_PostSection>[
      if (followed.isNotEmpty) _PostSection('Following', followed),
      if (suggested.isNotEmpty) _PostSection('Suggested', suggested),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Posts',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        ...sections.map(
          (section) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (sections.length > 1) ...[
                Text(
                  section.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
              ],
              ...section.items.map(
                (reel) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ExplorePostCard(
                    reel: reel,
                    isCustomer: _isCustomer,
                    isLiked: _likedReels.contains(reel.reelId),
                    onLike: () => _toggleLike(reel),
                    onComment: () => _openComments(reel),
                    onCreateRequest: () => _openCreateRequestFromPost(reel),
                    onViewPhotographer: () => AppRouter.goToPhotographerProfile(
                      context,
                      reel.photographerId,
                    ),
                    onShare: () => _shareReel(reel),
                    onReport: () => _reportContent(
                      targetId: reel.reelId,
                      targetType: 'reel',
                      targetOwnerId: reel.photographerId,
                    ),
                    onFollow: () => _toggleFollow(reel.photographerId),
                    isFollowing: _followingIds.contains(reel.photographerId),
                    canFollow: reel.photographerId != _userId,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PostSection {
  final String title;
  final List<ReelModel> items;

  const _PostSection(this.title, this.items);
}

class _ExplorePostCard extends StatelessWidget {
  final ReelModel reel;
  final bool isCustomer;
  final bool isLiked;
  final bool isFollowing;
  final bool canFollow;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onCreateRequest;
  final VoidCallback onViewPhotographer;
  final VoidCallback onReport;
  final VoidCallback onFollow;
  final VoidCallback onShare;

  const _ExplorePostCard({
    required this.reel,
    required this.isCustomer,
    required this.isLiked,
    required this.onLike,
    required this.onComment,
    required this.onCreateRequest,
    required this.onViewPhotographer,
    required this.onReport,
    required this.onFollow,
    required this.onShare,
    required this.isFollowing,
    required this.canFollow,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = reel.thumbnailUrl ?? reel.videoUrl;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PostCard(
          authorName: reel.photographerName,
          authorAvatarUrl: reel.photographerPhotoUrl,
          imageUrl: imageUrl,
          caption: reel.caption,
          onLike: onLike,
          onComment: onComment,
          onShare: onShare,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('${reel.likes} Ø¥Ø¹Ø¬Ø§Ø¨', style: textTheme.bodySmall),
            const SizedBox(width: 12),
            Text('${reel.comments} ØªØ¹Ù„ÙŠÙ‚', style: textTheme.bodySmall),
            const Spacer(),
            if (canFollow)
              TextButton(
                onPressed: onFollow,
                child: Text(isFollowing ? 'Ù…ØªØ§Ø¨Ø¹Ø© âœ“' : 'Ù…ØªØ§Ø¨Ø¹Ø©'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: onViewPhotographer,
                    child: const Text('Ø¹Ø±Ø¶ Ø§Ù„Ù…ØµÙˆØ±'),
                  ),
                  if (isCustomer)
                    ElevatedButton(
                      onPressed: onCreateRequest,
                      child: const Text('Ø·Ù„Ø¨ Ù†ÙØ³ Ø§Ù„Ø£Ø³Ù„ÙˆØ¨'),
                    ),
                ],
              ),
            ),
            IconButton(
              onPressed: onReport,
              icon: const Icon(Icons.flag_outlined),
              tooltip: 'Ø¥Ø¨Ù„Ø§Øº',
            ),
          ],
        ),
      ],
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  final ReelModel reel;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final VoidCallback onCommentAdded;

  const _CommentsSheet({
    required this.reel,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.onCommentAdded,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<CommentModel> _comments = [];
  bool _loading = true;
  bool _submitting = false;
  DateTime? _lastCommentAt;

  static const List<String> _blockedWords = [
    'Ø±Ù‚Ù…',
    'ÙˆØ§ØªØ³Ø§Ø¨',
    'whatsapp',
    'telegram',
    'tel',
  ];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final result = await ReelsDependencies.getReelComments().call(
        reelId: widget.reel.reelId,
      );
      if (result.isSuccess) {
        _comments
          ..clear()
          ..addAll(result.valueOrNull ?? []);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_containsPhone(text) || _containsUrl(text) || _containsBlocked(text)) {
      _showSnackBar(
        'ÙŠÙ…Ù†Ø¹ Ù…Ø´Ø§Ø±ÙƒØ© Ø£Ø±Ù‚Ø§Ù… Ø£Ùˆ Ø±ÙˆØ§Ø¨Ø· Ø£Ùˆ Ù…Ø­ØªÙˆÙ‰ Ù…Ø®Ø§Ù„Ù.',
      );
      return;
    }

    final now = DateTime.now();
    if (_lastCommentAt != null &&
        now.difference(_lastCommentAt!).inSeconds < 3) {
      _showSnackBar(
        'Ø§Ù„Ø±Ø¬Ø§Ø¡ Ø§Ù„Ø§Ù†ØªØ¸Ø§Ø± Ù‚Ø¨Ù„ Ø¥Ø±Ø³Ø§Ù„ ØªØ¹Ù„ÙŠÙ‚ Ø¢Ø®Ø±.',
      );
      return;
    }

    setState(() => _submitting = true);
    _lastCommentAt = now;

    final comment = CommentModel(
      commentId: const Uuid().v4(),
      reelId: widget.reel.reelId,
      userId: widget.userId,
      userName: widget.userName,
      userPhotoUrl: widget.userAvatarUrl,
      text: text,
      createdAt: DateTime.now(),
    );

    final result = await ReelsDependencies.addReelComment().call(
      comment: comment,
    );
    if (result.isSuccess) {
      _controller.clear();
      setState(() => _comments.insert(0, comment));
      widget.onCommentAdded();
    } else {
      _showSnackBar('ØªØ¹Ø°Ø± Ø¥Ø±Ø³Ø§Ù„ Ø§Ù„ØªØ¹Ù„ÙŠÙ‚.');
    }

    if (mounted) {
      setState(() => _submitting = false);
    }
  }

  bool _containsPhone(String text) {
    final digits = RegExp(r'\d{7,}');
    return digits.hasMatch(text);
  }

  bool _containsUrl(String text) {
    final url = RegExp(r'(https?:\\/\\/|www\\.)', caseSensitive: false);
    return url.hasMatch(text);
  }

  bool _containsBlocked(String text) {
    final lower = text.toLowerCase();
    return _blockedWords.any((word) => lower.contains(word));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ø§Ù„ØªØ¹Ù„ÙŠÙ‚Ø§Øª',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: controller,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: comment.userPhotoUrl != null
                                ? NetworkImage(comment.userPhotoUrl!)
                                : null,
                            child: comment.userPhotoUrl == null
                                ? const Icon(Icons.person_outline)
                                : null,
                          ),
                          title: Text(comment.userName),
                          subtitle: Text(comment.text),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Ø§ÙƒØªØ¨ ØªØ¹Ù„ÙŠÙ‚Ø§Ù‹...',
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _submitting ? null : _submitComment,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
