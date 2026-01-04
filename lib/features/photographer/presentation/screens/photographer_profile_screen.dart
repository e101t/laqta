import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/photographer_model.dart';
import 'package:luqta/core/models/portfolio_model.dart';
import 'package:luqta/core/models/review_model.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/widgets/app_buttons.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/photographer/photographer_dependencies.dart';
import 'package:luqta/features/photographer/presentation/mappers/photographer_presentation_mapper.dart';
import 'package:luqta/screens/booking/booking_request_screen.dart';
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
    if (_userData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to book: Photographer data not loaded'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingRequestScreen(
          photographerId: widget.photographerId,
          photographerName: _userData!.name,
        ),
      ),
    );
  }

  void _share() {
    final String shareText =
        'Check out this photographer: ${_userData!.name}\n'
        'Rating: ${_photographerData!.rate} (${_photographerData!.reviewsCount} reviews)\n'
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

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('حسابي')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                CTAButton(
                  text: 'إعادة المحاولة',
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
        ? 'أنثى'
        : _userData!.gender == 'male'
        ? 'ذكر'
        : null;
    final ageLabel = _userData!.age != null ? '${_userData!.age} سنة' : null;

    return Scaffold(
      backgroundColor: AppColors.background,
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
                          color: AppColors.primary,
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
                              style: AppTypography.h2,
                            ),
                          ),
                          if (_photographerData!.isTopRated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cta,
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
                                    style: AppTypography.caption.copyWith(
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

                      // Rating
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.starFilled,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_photographerData!.rate} (${_photographerData!.reviewsCount} ${localizations.reviews})',
                            style: AppTypography.bodyMedium.copyWith(
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
                                backgroundColor: AppColors.background,
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
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  spec,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.primary,
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
                        style: AppTypography.bodyMedium,
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
                                color: AppColors.primary,
                                onPressed: _openInstagram,
                              ),
                            if (_photographerData!.tiktok != null)
                              IconButton(
                                icon: const Icon(Icons.music_note),
                                color: AppColors.primary,
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
                            style: AppTypography.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${_photographerData!.basePrice.toStringAsFixed(0)} IQD',
                            style: AppTypography.price,
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
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: [
                    const Tab(text: 'الملخص'),
                    Tab(text: localizations.reviews),
                    const Tab(text: 'المعرض'),
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
          color: AppColors.surface,
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
      return const Center(child: Text('لا توجد صور في المعرض حالياً'));
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
      return const Center(child: Text('لا توجد تقييمات بعد'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reviews.length,
      itemBuilder: (context, index) {
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
                          Text('Customer', style: AppTypography.h4),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                size: 16,
                                color: i < review.rating
                                    ? AppColors.starFilled
                                    : AppColors.starEmpty,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _formatDateTime(review.createdAt),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (review.comment != null)
                  Text(review.comment!, style: AppTypography.bodyMedium),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(AppLocalizations localizations) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.place, color: AppColors.primary),
          title: Text(_userData?.governorate ?? ''),
          subtitle: const Text('المحافظة'),
        ),
        ListTile(
          leading: const Icon(Icons.price_change, color: AppColors.primary),
          title: Text(
            '${_photographerData!.basePrice.toStringAsFixed(0)} IQD',
            style: AppTypography.h4.copyWith(color: AppColors.primary),
          ),
          subtitle: Text(localizations.startingFrom),
        ),
        if (_photographerData!.specialties.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('التخصصات', style: AppTypography.h4),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photographerData!.specialties
                .map(
                  (s) => Chip(
                    label: Text(s),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
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
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
