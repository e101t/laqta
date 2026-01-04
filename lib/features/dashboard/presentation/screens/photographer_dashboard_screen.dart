import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:go_router/go_router.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/dashboard/dashboard_dependencies.dart';
import 'package:luqta/features/dashboard/domain/entities/dashboard_booking.dart';

class PhotographerDashboardScreen extends StatefulWidget {
  const PhotographerDashboardScreen({super.key});

  @override
  State<PhotographerDashboardScreen> createState() =>
      _PhotographerDashboardScreenState();
}

class _PhotographerDashboardScreenState
    extends State<PhotographerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  final List<DashboardBooking> _todayBookings = [];
  final List<DashboardBooking> _upcomingBookings = [];

  final Map<String, dynamic> _stats = {
    'todayBookings': 3,
    'totalBookings': 24,
    'avgRating': 4.8,
    'totalEarnings': 3600000.0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDashboardData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      final result = await DashboardDependencies.getPhotographerBookings().call(
        photographerId: userId,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to load dashboard bookings',
        );
      }
      final bookings = result.valueOrNull ?? <DashboardBooking>[];

      final today = DateTime.now();
      final todayStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      _todayBookings.clear();
      _upcomingBookings.clear();

      for (var booking in bookings) {
        final bookingDate =
            '${booking.date.year}-${booking.date.month.toString().padLeft(2, '0')}-${booking.date.day.toString().padLeft(2, '0')}';
        if (bookingDate == todayStr &&
            (booking.status == 'confirmed' || booking.status == 'pending')) {
          _todayBookings.add(booking);
        } else if (bookingDate.compareTo(todayStr) > 0 &&
            booking.status == 'confirmed') {
          _upcomingBookings.add(booking);
        }
      }
    } catch (e) {
      // Handle error, perhaps show snackbar
      if (kDebugMode) {
        debugPrint('Error loading dashboard data: $e');
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _acceptBooking(String bookingId) async {
    try {
      final result = await BookingDependencies.updateBookingStatus().call(
        bookingId: bookingId,
        status: 'confirmed',
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to accept booking',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking accepted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error accepting booking')),
        );
      }
    }
    _loadDashboardData();
  }

  Future<void> _rejectBooking(String bookingId) async {
    try {
      final result = await BookingDependencies.updateBookingStatus().call(
        bookingId: bookingId,
        status: 'rejected',
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to reject booking',
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Booking rejected')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error rejecting booking')),
        );
      }
    }
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'الإحصائيات',
            onPressed: () {
              context.push(AppRouter.analytics);
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              context.push(AppRouter.availability);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push(AppRouter.settings);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today,
                          label: 'Today',
                          value: _stats['todayBookings'].toString(),
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          label: 'Total',
                          value: _stats['totalBookings'].toString(),
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.star,
                          label: 'Rating',
                          value: _stats['avgRating'].toString(),
                          color: AppColors.cta,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.payments,
                          label: 'Earnings',
                          value:
                              '${(_stats['totalEarnings'] / 1000).toStringAsFixed(0)}K',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicator: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tabs: const [
                        Tab(text: 'Today'),
                        Tab(text: 'Upcoming'),
                        Tab(text: 'Past'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tab Content
                  SizedBox(
                    height: 500,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(_todayBookings, localizations),
                        _buildBookingsList(_upcomingBookings, localizations),
                        _buildEmptyState(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingsList(
    List<DashboardBooking> bookings,
    AppLocalizations localizations,
  ) {
    if (bookings.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(
          booking: booking,
          localizations: localizations,
          onAccept: () => _acceptBooking(booking.id),
          onReject: () => _rejectBooking(booking.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: EmptyState(
        icon: Icons.event_busy,
        title: 'No Bookings',
        message: 'You have no bookings for this period',
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h2.copyWith(color: color)),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final DashboardBooking booking;
  final AppLocalizations localizations;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _BookingCard({
    required this.booking,
    required this.localizations,
    required this.onAccept,
    required this.onReject,
  });

  Color _getStatusColor() {
    switch (booking.status) {
      case 'confirmed':
        return AppColors.confirmed;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
        return AppColors.rejected;
      case 'done':
        return AppColors.done;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName, style: AppTypography.h4),
                      Text(booking.type, style: AppTypography.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getStatusColor()),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: AppTypography.caption.copyWith(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 4),
                Text(booking.time, style: AppTypography.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.payments, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${booking.price.toStringAsFixed(0)} IQD',
                  style: AppTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            if (booking.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: Text(localizations.reject),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      child: Text(localizations.accept),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
