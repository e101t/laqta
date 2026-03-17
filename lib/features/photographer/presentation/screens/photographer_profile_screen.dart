import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/models/photographer_model.dart';
import 'package:laqta/core/models/portfolio_model.dart';
import 'package:laqta/core/models/review_model.dart';
import 'package:laqta/core/models/user_model.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/app_buttons.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/photographer/photographer_dependencies.dart';
import 'package:laqta/features/photographer/presentation/mappers/photographer_presentation_mapper.dart';
import 'package:laqta/features/trust/domain/entities/trust_stats.dart';
import 'package:laqta/features/trust/trust_dependencies.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PhotographerProfileScreen extends StatefulWidget {
  final String photographerId;

  const PhotographerProfileScreen({super.key, required this.photographerId});

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState extends State<PhotographerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isFavorite = false;
  String? _errorMessage;

  // Data models
  UserModel? _userData;
  PhotographerModel? _photographerData;
  PortfolioModel? _portfolioData;
  List<ReviewModel> _reviews = [];
  TrustStats? _trustStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPhotographerData();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPhotographerData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await PhotographerDependencies.getPhotographerProfile()
          .call(photographerId: widget.photographerId);
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError(
          result.failureOrNull?.message ?? 'Photographer not found',
        );
      }

      final bundle = result.valueOrNull!;
      _userData = PhotographerPresentationMapper.toUserModel(bundle.user);
      _photographerData = PhotographerPresentationMapper.toPhotographerModel(
        bundle.photographer,
      );
      _portfolioData = bundle.portfolio == null
          ? null
          : PhotographerPresentationMapper.toPortfolioModel(bundle.portfolio!);
      _reviews = PhotographerPresentationMapper.toReviewModels(bundle.reviews);

      final trustResult = await TrustDependencies.getTrustStats().call(
        widget.photographerId,
      );
      if (trustResult.isSuccess) {
        _trustStats = trustResult.valueOrNull;
      }
    } catch (e) {
      _errorMessage = 'Failed to load photographer data';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIfFavorite() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) return;

    try {
      final result = await PhotographerDependencies.checkFavoriteStatus().call(
        userId: userId,
        photographerId: widget.photographerId,
      );
      if (!result.isSuccess) {
        return;
      }
      if (mounted) {
        setState(() => _isFavorite = result.valueOrNull ?? false);
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }

  Future<void> _toggleFavorite() async {
    final userResult = await AuthDependencies.getCurrentUser().call();
    final userId = userResult.valueOrNull?.id;
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add favorites')),
        );
      }
      return;
    }

    final wasFavorite = _isFavorite;
    setState(() => _isFavorite = !_isFavorite);

    try {
      final result = await PhotographerDependencies.setFavoriteStatus().call(
        userId: userId,
        photographerId: widget.photographerId,
        isFavorite: _isFavorite,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to update favorite',
        );
      }
    } catch (e) {
      // Revert the state on error
      setState(() => _isFavorite = wasFavorite);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    }
  }

  void _bookNow() {
    AppRouter.goToCreateRequest(context);
  }

  void _share() {
    final trustLabel = _trustLabel();
    final String shareText =
        'Check out this photographer: ${_userData!.name}\n'
        'Trust score: $trustLabel\n'
        'Specialties: ${_photographerData!.specialties.join(', ')}\n'
        'Starting from: ${_photographerData!.basePrice.toStringAsFixed(0)} IQD';

    SharePlus.instance.share(ShareParams(text: shareText));
  }

  Future<void> _openInstagram() async {
    if (_photographerData!.instagram == null) return;

    String instagramUrl = _photographerData!.instagram!;
    // Ensure URL has https:// prefix
    if (!instagramUrl.startsWith('http://') &&
        !instagramUrl.startsWith('https://')) {
      instagramUrl = 'https://$instagramUrl';
    }

    // If it's just a username, create the full Instagram URL
    if (!instagramUrl.contains('instagram.com/') &&
        instagramUrl.contains('@')) {
      final username = instagramUrl
          .replaceAll('@', '')
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      instagramUrl = 'https://instagram.com/$username';
    } else if (!instagramUrl.contains('instagram.com/') &&
        !instagramUrl.startsWith('https://instagram.com/')) {
      // Handle case where it's just a username without @
      final username = instagramUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      instagramUrl = 'https://instagram.com/$username';
    }

    try {
      final uri = Uri.parse(instagramUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Cannot open Instagram link');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open Instagram');
    }
  }

  Future<void> _openTikTok() async {
    if (_photographerData!.tiktok == null) return;

    String tiktokUrl = _photographerData!.tiktok!;
    // Ensure URL has https:// prefix
    if (!tiktokUrl.startsWith('http://') && !tiktokUrl.startsWith('https://')) {
      tiktokUrl = 'https://$tiktokUrl';
    }

    // If it's just a username, create the full TikTok URL
    if (!tiktokUrl.contains('tiktok.com/') && tiktokUrl.contains('@')) {
      final username = tiktokUrl
          .replaceAll('@', '')
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      tiktokUrl = 'https://tiktok.com/@$username';
    } else if (!tiktokUrl.contains('tiktok.com/') &&
        !tiktokUrl.startsWith('https://tiktok.com/')) {
      // Handle case where it's just a username without @
      final username = tiktokUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      tiktokUrl = 'https://tiktok.com/@$username';
    }

    try {
      final uri = Uri.parse(tiktokUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Cannot open TikTok link');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open TikTok');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${difference.inDays ~/ 365} year${difference.inDays ~/ 365 == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${difference.inDays ~/ 30} month${difference.inDays ~/ 30 == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _trustLabel() {
    double average = 0;
    int count = 0;

    if (_trustStats != null && _trustStats!.reviewCount > 0) {
      average =
          (_trustStats!.avgQuality +
                  _trustStats!.avgCommunication +
                  _trustStats!.avgOnTime +
                  _trustStats!.avgDelivery) /
              4;
      count = _trustStats!.reviewCount;
    } else if (_reviews.isNotEmpty) {
      final total = _reviews.fold<double>(0, (sum, review) {
        return sum +
            review.qualityRating +
            review.communicationRating +
            review.onTimeRating +
            review.deliverySpeedRating;
      });
      average = total / (_reviews.length * 4);
      count = _reviews.length;
    }

    if (count == 0) return 'New';
    if (average >= 4.2) return 'High';
    if (average >= 3.2) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Ø­Ø³Ø§Ø¨ÙŠ')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: scheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CTAButton(
                  text: 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©',
                  onPressed: _loadPhotographerData,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_userData == null || _photographerData == null) {
      return const Scaffold(body: Center(child: Text('No data available')));
    }

    final genderLabel = _userData!.gender == 'female'
        ? 'Ø£Ù†Ø«Ù‰'
        : _userData!.gender == 'male'
        ? 'Ø°ÙƒØ±'
        : null;
    final ageLabel = _userData!.age != null ? '${_userData!.age} Ø³Ù†Ø©' : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _userData!.photoUrl != null
                      ? Image.network(_userData!.photoUrl!, fit: BoxFit.cover)
                      : Container(
                          color: scheme.primary,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                color: _isFavorite ? Colors.red : Colors.white,
                onPressed: _toggleFavorite,
              ),
              IconButton(icon: const Icon(Icons.share), onPressed: _share),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _userData!.name,
                              style: textTheme.headlineSmall,
                            ),
                          ),
                          if (_photographerData!.isTopRated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.secondary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    localizations.topRated,
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Trust Score
                      Row(
                        children: [
                          Icon(
                            Icons.verified,
                            color: scheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Trust: ${_trustLabel()}',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if ((_userData!.username?.isNotEmpty ?? false) ||
                          genderLabel != null ||
                          ageLabel != null) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (_userData!.username?.isNotEmpty ?? false)
                              _ProfileChip(
                                icon: Icons.alternate_email,
                                label: '@${_userData!.username}',
                              ),
                            if (genderLabel != null)
                              _ProfileChip(
                                icon: _userData!.gender == 'female'
                                    ? Icons.female
                                    : Icons.male,
                                label: genderLabel,
                              ),
                            if (ageLabel != null)
                              _ProfileChip(icon: Icons.cake, label: ageLabel),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Governorates
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _photographerData!.governorates
                            .map(
                              (gov) => Chip(
                                avatar: const Icon(Icons.location_on, size: 16),
                                label: Text(gov),
                                backgroundColor: scheme.surface,
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Specialties
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _photographerData!.specialties
                            .map(
                              (spec) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  spec,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: scheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Bio
                      Text(
                        _photographerData!.bio,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Social Links
                      if (_photographerData!.instagram != null ||
                          _photographerData!.tiktok != null)
                        Row(
                          children: [
                            if (_photographerData!.instagram != null)
                              IconButton(
                                icon: const Icon(Icons.camera_alt),
                                color: scheme.primary,
                                onPressed: _openInstagram,
                              ),
                            if (_photographerData!.tiktok != null)
                              IconButton(
                                icon: const Icon(Icons.music_note),
                                color: scheme.primary,
                                onPressed: _openTikTok,
                              ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // Price
                      Row(
                        children: [
                          Text(
                            localizations.startingFrom,
                            style: textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${_photographerData!.basePrice.toStringAsFixed(0)} IQD',
                            style: textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Divider(height: 32),

                // Tabs
                TabBar(
                  controller: _tabController,
                  labelColor: scheme.primary,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  indicatorColor: scheme.primary,
                  tabs: [
                    const Tab(text: 'Ø§Ù„Ù…Ù„Ø®Øµ'),
                    Tab(text: localizations.reviews),
                    const Tab(text: 'Ø§Ù„Ù…Ø¹Ø±Ø¶'),
                  ],
                ),

                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSummaryTab(localizations),
                      _buildReviewsTab(localizations),
                      _buildPortfolioTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CTAButton(
          text: localizations.bookNow,
          onPressed: _bookNow,
          icon: Icons.calendar_today,
        ),
      ),
    );
  }

  Widget _buildPortfolioTab() {
    final images = _portfolioData?.images ?? [];
    if (images.isEmpty) {
      return const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ ØµÙˆØ± ÙÙŠ Ø§Ù„Ù…Ø¹Ø±Ø¶ Ø­Ø§Ù„ÙŠØ§Ù‹'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final image = images[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(image.url),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(AppLocalizations localizations) {
    if (_reviews.isEmpty) {
      return const Center(child: Text('No reviews yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
        final textTheme = Theme.of(context).textTheme;
        final review = _reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client', style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(review.createdAt),
                            style: textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MetricChip(label: 'Quality', value: review.qualityRating),
                    _MetricChip(
                      label: 'Communication',
                      value: review.communicationRating,
                    ),
                    _MetricChip(label: 'On time', value: review.onTimeRating),
                    _MetricChip(
                      label: 'Delivery',
                      value: review.deliverySpeedRating,
                    ),
                    if (review.recommend != null)
                      _FlagChip(
                        label: review.recommend!
                            ? 'Recommended'
                            : 'Not recommended',
                        positive: review.recommend!,
                      ),
                  ],
                ),
                if (review.comment != null) ...[
                  const SizedBox(height: 12),
                  Text(review.comment!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(AppLocalizations localizations) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: Icon(Icons.place, color: scheme.primary),
          title: Text(_userData?.governorate ?? ''),
          subtitle: const Text('Ø§Ù„Ù…Ø­Ø§ÙØ¸Ø©'),
        ),
        ListTile(
          leading: Icon(Icons.price_change, color: scheme.primary),
          title: Text(
            '${_photographerData!.basePrice.toStringAsFixed(0)} IQD',
            style: textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          subtitle: Text(localizations.startingFrom),
        ),
        if (_photographerData!.specialties.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Ø§Ù„ØªØ®ØµØµØ§Øª', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photographerData!.specialties
                .map(
                  (s) => Chip(
                    label: Text(s),
                    backgroundColor: scheme.primaryContainer,
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _bookNow,
          icon: const Icon(Icons.calendar_month),
          label: Text(localizations.bookNow),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ],
    );
  }
}

class _ProfileChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 4),
          Text(label, style: textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final int value;

  const _MetricChip({required this.label, required this.value});

  Color _chipColor(ColorScheme scheme) {
    if (value >= 4) return scheme.tertiary;
    if (value >= 3) return scheme.secondary;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _chipColor(scheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(width: 6),
          Text(
            '$value/5',
            style: textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  final bool positive;

  const _FlagChip({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = positive ? scheme.tertiary : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.thumb_up : Icons.thumb_down,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
