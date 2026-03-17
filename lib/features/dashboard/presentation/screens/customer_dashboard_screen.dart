import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/models/story_model.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/models/booking_model.dart';
import 'package:laqta/core/services/story_service.dart';
import 'package:laqta/core/theme/laqta_tokens.dart';
import 'package:laqta/core/utils/runtime_env.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/core/widgets/skeleton_loaders.dart';
import 'package:laqta/core/widgets/story_bubble.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:laqta/features/explore/presentation/screens/story_viewer_screen.dart';
import 'package:intl/intl.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  StoryService? _storyService;
  final PageController _offersController = PageController(
    viewportFraction: 0.9,
  );
  Timer? _offersTimer;
  int _offersIndex = 0;

  String _userId = '';
  bool _isLoading = true;
  bool _hasError = false;
  final List<BookingModel> _upcomingBookings = [];
  final List<_FeaturedProduct> _featuredProducts = [];

  static const List<_FeaturedProduct> _demoFeaturedProducts = [
    _FeaturedProduct(
      id: 'demo_product_1',
      title: 'Ø¥Ø·Ø§Ø± ØµÙˆØ± ÙØ§Ø®Ø±',
      subtitle: 'Ø®Ø´Ø¨ Ø·Ø¨ÙŠØ¹ÙŠ + Ø²Ø¬Ø§Ø¬ Ù…Ù‚Ø§ÙˆÙ… Ù„Ù„Ø®Ø¯Ø´',
      priceIQD: 35000,
      assetPath: 'assets/images/offers/offer_1.png',
      badge: 'Ø¬Ø¯ÙŠØ¯',
    ),
    _FeaturedProduct(
      id: 'demo_product_2',
      title: 'Ø£Ù„Ø¨ÙˆÙ… Ù…Ø·Ø¨ÙˆØ¹',
      subtitle: 'ÙˆØ±Ù‚ Ø¹Ø§Ù„ÙŠ Ø§Ù„Ø¬ÙˆØ¯Ø© + ØªØµÙ…ÙŠÙ… Ø£Ù†ÙŠÙ‚',
      priceIQD: 65000,
      assetPath: 'assets/images/offers/offer_2.png',
      badge: 'Ø§Ù„Ø£ÙƒØ«Ø± Ù…Ø¨ÙŠØ¹Ù‹Ø§',
    ),
    _FeaturedProduct(
      id: 'demo_product_3',
      title: 'Ø¬Ù„Ø³Ø© ØªØµÙˆÙŠØ± Ù…Ù†ØªØ¬Ø§Øª',
      subtitle: 'Ø¨Ø§Ù‚Ø© Ù…Ù†Ø§Ø³Ø¨Ø© Ù„Ù„Ù…ØªØ§Ø¬Ø± ÙˆØ§Ù„Ù…ØªØ§Ø¬Ø± Ø§Ù„Ø¥Ù„ÙƒØªØ±ÙˆÙ†ÙŠØ©',
      priceIQD: 120000,
      assetPath: 'assets/images/offers/offer_3.png',
      badge: 'Ø¹Ø±Ø¶',
    ),
  ];

  bool _storiesLoading = true;
  String? _storiesError;
  List<StoryModel> _stories = [];

  final List<_OfferSlide> _offerSlides = const [
    _OfferSlide(
      title: 'Ø¬Ù„Ø³Ø§Øª Ø¨ÙˆØ±ØªØ±ÙŠÙ‡ ÙØ§Ø®Ø±Ø©',
      subtitle: 'Ø®ØµÙ… Ù¢Ù Ùª Ø¹Ù„Ù‰ Ø¬Ù„Ø³Ø§Øª Ø§Ù„ØªØµÙˆÙŠØ± Ø§Ù„Ø´Ø®ØµÙŠØ© Ù‡Ø°Ø§ Ø§Ù„Ø£Ø³Ø¨ÙˆØ¹',
      cta: 'Ø§Ø­Ø¬Ø² Ø§Ù„Ø¢Ù†',
      assetPath: 'assets/images/offers/offer_1.png',
    ),
    _OfferSlide(
      title: 'ØªØµÙˆÙŠØ± Ù…Ù†Ø§Ø³Ø¨Ø§Øª Ù…Ù…ÙŠØ²',
      subtitle: 'Ø§Ø­Ø¬Ø² Ø¨Ø§Ù‚Ø© Ø§Ù„Ù…Ù†Ø§Ø³Ø¨Ø§Øª ÙˆØ§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø£Ù„Ø¨ÙˆÙ… Ù…Ø·Ø¨ÙˆØ¹ Ù…Ø¬Ø§Ù†Ù‹Ø§',
      cta: 'Ø§Ø³ØªÙƒØ´Ù Ø§Ù„Ø¨Ø§Ù‚Ø©',
      assetPath: 'assets/images/offers/offer_2.png',
    ),
    _OfferSlide(
      title: 'ØªØµÙˆÙŠØ± Ù…Ù†ØªØ¬Ø§Øª Ø§Ø­ØªØ±Ø§ÙÙŠ',
      subtitle: 'Ù„Ø£ØµØ­Ø§Ø¨ Ø§Ù„Ù…ØªØ§Ø¬Ø±: Ø¬Ù„Ø³Ø§Øª Ø§Ø­ØªØ±Ø§ÙÙŠØ© Ø¨Ø£Ø³Ø¹Ø§Ø± Ø®Ø§ØµØ©',
      cta: 'Ø§Ø¨Ø¯Ø£ Ø§Ù„Ø¢Ù†',
      assetPath: 'assets/images/offers/offer_3.png',
    ),
  ];
  bool get _useDemoContent =>
      AppConstants.enableDemoContent && kDebugMode && !isFlutterTestEnv();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadDashboard());
      unawaited(_loadStories());
      _startOffersAutoScroll();
    });
  }

  void _startOffersAutoScroll() {
    _offersTimer?.cancel();
    _offersTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (_offerSlides.isEmpty || !_offersController.hasClients) return;
      final nextIndex = (_offersIndex + 1) % _offerSlides.length;
      _offersController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _offersTimer?.cancel();
    _offersController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    if (kDebugMode) {
      if (Firebase.apps.isNotEmpty) {
        final authUser = FirebaseAuth.instance.currentUser;
        final app = Firebase.app();
        debugPrint(
          'CustomerDashboardScreen:_loadDashboard auth=${authUser?.uid ?? 'null'} '
          'project=${app.name}:${app.options.projectId}',
        );
      } else {
        debugPrint(
          'CustomerDashboardScreen:_loadDashboard Firebase not initialized',
        );
      }
    }

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing user');
      }
      _userId = userId;

      final bookingResult = await BookingDependencies.getMyBookings().call(
        userId: userId,
      );
      if (bookingResult.isSuccess) {
        _upcomingBookings
          ..clear()
          ..addAll(
            (bookingResult.valueOrNull ?? [])
                .map(BookingPresentationMapper.toModel)
                .where(
                  (booking) =>
                      booking.status != 'canceled' &&
                      booking.status != 'completed' &&
                      booking.status != 'done',
                )
                .toList(),
          );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load dashboard: $e');
      }
      if (!mounted) return;
      if (_useDemoContent) {
        _applyDemoDashboard();
        setState(() {
          _isLoading = false;
          _hasError = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _applyDemoDashboard() {
    final now = DateTime.now();
    _featuredProducts
      ..clear()
      ..addAll(_demoFeaturedProducts);

    _upcomingBookings
      ..clear()
      ..addAll([
        BookingModel(
          id: 'demo_booking_1',
          customerId: 'demo_client',
          photographerId: 'demo_ph_1',
          date: '2026-02-10',
          time: '06:30 PM',
          duration: 120,
          type: 'Ø¬Ù„Ø³Ø© Ø¹Ø§Ø¦Ù„ÙŠØ©',
          price: 150000,
          status: 'confirmed',
          payment: PaymentInfo(
            status: 'deposit_paid',
            amount: 50000,
            paidAt: now.subtract(const Duration(days: 1)),
          ),
          location: LocationInfo(text: 'Ø¨ØºØ¯Ø§Ø¯ - Ø§Ù„Ù…Ù†ØµÙˆØ±'),
          deliverables: DeliverablesInfo(
            photosCount: 25,
            includesEditing: true,
          ),
          timeline: BookingTimeline(
            confirmedAt: now.subtract(const Duration(days: 1)),
          ),
          createdAt: now.subtract(const Duration(days: 2)),
          updatedAt: now,
        ),
        BookingModel(
          id: 'demo_booking_2',
          customerId: 'demo_client',
          photographerId: 'demo_ph_3',
          date: '2026-02-20',
          time: '05:00 PM',
          duration: 90,
          type: 'ØªØµÙˆÙŠØ± Ù…Ù†Ø§Ø³Ø¨Ø§Øª',
          price: 220000,
          status: 'pending',
          payment: PaymentInfo(status: 'pending', amount: 0),
          location: LocationInfo(text: 'Ø£Ø±Ø¨ÙŠÙ„ - Ø¹ÙŠÙ†ÙƒØ§ÙˆØ§'),
          deliverables: DeliverablesInfo(
            photosCount: 40,
            includesEditing: true,
          ),
          timeline: BookingTimeline(),
          createdAt: now.subtract(const Duration(days: 1)),
          updatedAt: now,
        ),
      ]);
  }

  List<_FeaturedProduct> _visibleProducts() =>
      _useDemoContent ? _demoFeaturedProducts : _featuredProducts;

  String _formatIQD(BuildContext context, int amount) {
    final locale = Localizations.localeOf(context).toString();
    final formatted = NumberFormat.decimalPattern(locale).format(amount);
    return '$formatted Ø¯.Ø¹';
  }

  Future<void> _loadStories() async {
    setState(() {
      _storiesLoading = true;
      _storiesError = null;
    });
    try {
      final service = _storyService ?? StoryService();
      _storyService = service;
      final stories = await service.fetchActiveStories();
      if (!mounted) return;
      setState(() {
        _stories = stories.isEmpty && _useDemoContent
            ? _buildDemoStories()
            : stories;
        _storiesLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (_useDemoContent) {
        setState(() {
          _stories = _buildDemoStories();
          _storiesLoading = false;
          _storiesError = null;
        });
      } else {
        setState(() {
          _storiesLoading = false;
          _storiesError = 'Failed to load stories';
        });
      }
    }
  }

  List<StoryModel> _buildDemoStories() {
    final now = DateTime.now();
    return [
      StoryModel(
        storyId: 'demo_story_1',
        photographerId: 'demo_ph_1',
        photographerName: 'Ù…Ø±ÙˆØ© Ø§Ù„Ø­Ø±Ø¨ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_auth.png',
        caption: 'Ø¨ÙˆØ±ØªØ±ÙŠÙ‡ ÙØ§Ø®Ø± Ø¨Ø¥Ø¶Ø§Ø¡Ø© Ø°Ù‡Ø¨ÙŠØ© Ù†Ø§Ø¹Ù…Ø©.',
        createdAt: now.subtract(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(hours: 23)),
        isActive: true,
      ),
      StoryModel(
        storyId: 'demo_story_2',
        photographerId: 'demo_ph_2',
        photographerName: 'Ø³ÙŠÙ Ø§Ù„ÙƒØ¹Ø¨ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_role.png',
        caption: 'Ù…Ù†Ø§Ø³Ø¨Ø§Øª Ø¨Ù„Ù…Ø³Ø© Ø³ÙŠÙ†Ù…Ø§Ø¦ÙŠØ© Ø£Ù†ÙŠÙ‚Ø©.',
        createdAt: now.subtract(const Duration(hours: 3)),
        expiresAt: now.add(const Duration(hours: 21)),
        isActive: true,
      ),
      StoryModel(
        storyId: 'demo_story_3',
        photographerId: 'demo_ph_3',
        photographerName: 'Ù†ÙˆØ± Ø§Ù„Ù‡Ø§Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_welcome.png',
        caption: 'ØªØµÙˆÙŠØ± Ù…Ù†ØªØ¬Ø§Øª Ø¨Ø®Ù„ÙÙŠØ© Ù†Ø¸ÙŠÙØ© ÙˆÙ„Ù…Ø³Ø© ÙØ§Ø®Ø±Ø©.',
        createdAt: now.subtract(const Duration(hours: 6)),
        expiresAt: now.add(const Duration(hours: 18)),
        isActive: true,
      ),
      StoryModel(
        storyId: 'demo_story_4',
        photographerId: 'demo_ph_4',
        photographerName: 'Ø±Ù†ÙŠÙ… Ø§Ù„Ø¨ØºØ¯Ø§Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_auth.png',
        caption: 'Ø¬Ù„Ø³Ø§Øª Ø¹Ø§Ø¦Ù„ÙŠØ© Ø¯Ø§ÙØ¦Ø© ÙÙŠ Ø§Ù„Ø¶ÙˆØ¡ Ø§Ù„Ø·Ø¨ÙŠØ¹ÙŠ.',
        createdAt: now.subtract(const Duration(hours: 8)),
        expiresAt: now.add(const Duration(hours: 16)),
        isActive: true,
      ),
      StoryModel(
        storyId: 'demo_story_5',
        photographerId: 'demo_ph_5',
        photographerName: 'Ø¹Ù…Ø± Ø§Ù„Ø³Ø¹Ø¯ÙŠ',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_role.png',
        caption: 'ØªØµÙˆÙŠØ± Ø·Ø¹Ø§Ù… Ø§Ø­ØªØ±Ø§ÙÙŠ Ù„Ø¥Ø¨Ø±Ø§Ø² Ø§Ù„ØªÙØ§ØµÙŠÙ„.',
        createdAt: now.subtract(const Duration(hours: 10)),
        expiresAt: now.add(const Duration(hours: 14)),
        isActive: true,
      ),
      StoryModel(
        storyId: 'demo_story_6',
        photographerId: 'demo_ph_6',
        photographerName: 'Ø²Ù‡Ù€Ø±Ø§Ø¡ Ø³Ø§Ù„Ù…',
        photographerPhotoUrl: 'assets/images/placeholder.jpg',
        imageUrl: 'assets/images/hero_welcome.png',
        caption: 'ØªØµÙˆÙŠØ± Ø£Ø·ÙØ§Ù„ Ø¨Ø£Ø³Ù„ÙˆØ¨ Ù‡Ø§Ø¯Ø¦ ÙˆØ¢Ù…Ù†.',
        createdAt: now.subtract(const Duration(hours: 12)),
        expiresAt: now.add(const Duration(hours: 12)),
        isActive: true,
      ),
    ];
  }

  void _openStoryViewer(List<StoryModel> stories, int index) {
    if (stories.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryViewerScreen(
          stories: stories,
          initialIndex: index,
          currentUserId: _userId,
          isCustomer: true,
          onCreateRequest: _openCreateRequestFromStory,
        ),
      ),
    );
  }

  void _openCreateRequestFromStory(StoryModel story) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateRequestScreen(
          prefillNotes:
              'Ù…Ø±Ø¬Ø¹ Ù…Ù† Ù‚ØµØ© Ø§Ù„Ù…ØµÙˆØ± ${story.photographerName}: ${story.caption ?? ''}',
          prefillReferenceImages: [story.imageUrl],
          prefillSelectedPhotographerId: story.photographerId,
        ),
      ),
    );
  }

  Widget _buildOffersSlider() {
    if (_offerSlides.isEmpty) {
      return const SizedBox.shrink();
    }

    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ø§Ù„Ø¹Ø±ÙˆØ¶ Ø§Ù„Ù…Ù…ÙŠØ²Ø©',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _offersController,
            itemCount: _offerSlides.length,
            onPageChanged: (index) => setState(() => _offersIndex = index),
            itemBuilder: (context, index) {
              final slide = _offerSlides[index];
              return _OfferSlideCard(
                slide: slide,
                onTap: () => AppRouter.goToCreateRequest(context),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_offerSlides.length, (index) {
            final isActive = index == _offersIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 22 : 8,
              decoration: BoxDecoration(
                color: isActive ? LaqtaColors.accent : LaqtaColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStoriesSection() {
    if (_storiesLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ø§Ù„Ù‚ØµØµ',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ShimmerLoading(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, index) => const SkeletonBox(
                  width: 68,
                  height: 68,
                  borderRadius: BorderRadius.all(Radius.circular(40)),
                ),
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemCount: 6,
              ),
            ),
          ),
        ],
      );
    }

    if (_storiesError != null) {
      return EmptyStates.error(message: _storiesError, onRetry: _loadStories);
    }

    if (_stories.isEmpty) {
      return EmptyStates.noStories();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ø§Ù„Ù‚ØµØµ',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _stories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final story = _stories[index];
              return StoryBubble(
                title: story.photographerName,
                imageUrl: story.photographerPhotoUrl,
                isViewed: _userId.isNotEmpty && story.hasUserViewed(_userId),
                onTap: () => _openStoryViewer(_stories, index),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.home),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => AppRouter.goToSearch(context),
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError
          ? EmptyStates.error(onRetry: _loadDashboard)
          : RefreshIndicator(
              onRefresh: () async {
                await _loadDashboard();
                await _loadStories();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [scheme.primary, scheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.bookWithConfidence,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          localizations.requestQuickPrompt,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CTAButton(
                          text: localizations.createRequest,
                          onPressed: () => AppRouter.goToCreateRequest(context),
                          icon: Icons.add,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildOffersSlider(),
                  const SizedBox(height: 24),
                  _buildStoriesSection(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.featuredProducts,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRouter.goToShop(context),
                        child: Text(localizations.viewAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_visibleProducts().isEmpty)
                    EmptyState(
                      icon: Icons.storefront_outlined,
                      title: localizations.noProducts,
                      message: localizations.productsEmptyMessage,
                      emoji: 'ðŸ›ï¸',
                    )
                  else
                    SizedBox(
                      height: 190,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _visibleProducts().length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) => _FeaturedProductCard(
                          product: _visibleProducts()[index],
                          priceLabel: _formatIQD(
                            context,
                            _visibleProducts()[index].priceIQD,
                          ),
                          onTap: () => AppRouter.goToShop(context),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        localizations.upcomingBookings,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () => AppRouter.goToBookings(context),
                        child: Text(localizations.viewAll),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_upcomingBookings.isEmpty)
                    EmptyState(
                      icon: Icons.event_busy,
                      title: localizations.noBookings,
                      message: localizations.noBookingsMessage,
                    )
                  else
                    Column(
                      children: _upcomingBookings
                          .take(3)
                          .map(
                            (booking) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(booking.type),
                                subtitle: Text(
                                  '${booking.date} - ${booking.time}',
                                ),
                                trailing: Text(
                                  booking.status.toUpperCase(),
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                  ),
                                ),
                                onTap: () => AppRouter.goToBookingDetails(
                                  context,
                                  booking.id,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
            ),
    );
  }
}

class _FeaturedProduct {
  final String id;
  final String title;
  final String subtitle;
  final int priceIQD;
  final String assetPath;
  final String? badge;

  const _FeaturedProduct({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.priceIQD,
    required this.assetPath,
    this.badge,
  });
}

class _FeaturedProductCard extends StatelessWidget {
  final _FeaturedProduct product;
  final String priceLabel;
  final VoidCallback onTap;

  const _FeaturedProductCard({
    required this.product,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 280,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: scheme.onSurface.withValues(alpha: 0.10),
              ),
              boxShadow: LaqtaShadows.soft,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      product.assetPath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                LaqtaColors.primary.withValues(alpha: 0.95),
                                LaqtaColors.accent.withValues(alpha: 0.35),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.storefront_outlined,
                              color: Colors.white70,
                              size: 44,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.10),
                            Colors.black.withValues(alpha: 0.70),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (product.badge != null)
                    PositionedDirectional(
                      top: 12,
                      start: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Text(
                          product.badge!,
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    bottom: 12,
                    start: 12,
                    end: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                priceLabel,
                                style: textTheme.titleSmall?.copyWith(
                                  color: LaqtaColors.accent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: LaqtaColors.accent,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                AppLocalizations.of(context).orderNow,
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferSlide {
  final String title;
  final String subtitle;
  final String cta;
  final String assetPath;

  const _OfferSlide({
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.assetPath,
  });
}

class _OfferSlideCard extends StatelessWidget {
  final _OfferSlide slide;
  final VoidCallback? onTap;

  const _OfferSlideCard({required this.slide, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    slide.assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              LaqtaColors.primary.withValues(alpha: 0.95),
                              LaqtaColors.accent.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.white70,
                            size: 44,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.55),
                          LaqtaColors.primary.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.35),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: LaqtaColors.accent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: LaqtaColors.accent.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_outlined,
                                size: 14,
                                color: LaqtaColors.accent,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ø¹Ø±Ø¶',
                                style: textTheme.labelSmall?.copyWith(
                                  color: LaqtaColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          slide.title,
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          slide.subtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LaqtaColors.accent,
                              foregroundColor: scheme.onSecondary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  slide.cta,
                                  style: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
