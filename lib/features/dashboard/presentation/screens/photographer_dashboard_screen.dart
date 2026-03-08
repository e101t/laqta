import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
        if (!mounted) return;
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
            (booking.status == 'confirmed' ||
                booking.status == 'pending' ||
                booking.status == 'in_progress' ||
                booking.status == 'delivered' ||
                booking.status == 'revision_requested')) {
          _todayBookings.add(booking);
        } else if (bookingDate.compareTo(todayStr) > 0 &&
            (booking.status == 'confirmed' ||
                booking.status == 'in_progress' ||
                booking.status == 'delivered' ||
                booking.status == 'revision_requested')) {
          _upcomingBookings.add(booking);
        }
      }
    } catch (e) {
      // Handle error, perhaps show snackbar
      if (kDebugMode) {
        debugPrint('Error loading dashboard data: $e');
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _acceptBooking(String bookingId) async {
    final localizations = AppLocalizations.of(context);
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
        ).showSnackBar(SnackBar(content: Text(localizations.bookingAcceptedMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bookingAcceptFailed)),
        );
      }
    }
    _loadDashboardData();
  }

  Future<void> _rejectBooking(String bookingId) async {
    final localizations = AppLocalizations.of(context);
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
        ).showSnackBar(SnackBar(content: Text(localizations.bookingRejectedMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bookingRejectFailed)),
        );
      }
    }
    _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.dashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: localizations.analyticsLabel,
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
                          label: localizations.todayLabel,
                          value: _stats['todayBookings'].toString(),
                          color: scheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.check_circle,
                          label: localizations.totalBookings,
                          value: _stats['totalBookings'].toString(),
                          color: scheme.tertiary,
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
                          label: localizations.rating,
                          value: _stats['avgRating'].toString(),
                          color: scheme.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event_available,
                          label: localizations.upcomingLabel,
                          value: _upcomingBookings.length.toString(),
                          color: scheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: scheme.primary,
                      unselectedLabelColor: scheme.onSurfaceVariant,
                      indicator: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tabs: [
                        Tab(text: localizations.todayLabel),
                        Tab(text: localizations.upcomingLabel),
                        Tab(text: localizations.past),
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
        title: AppLocalizations.of(context).noBookings,
        message: AppLocalizations.of(context).noBookingsMessage,
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
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: textTheme.labelSmall),
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

  Color _getStatusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (booking.status) {
      case 'confirmed':
        return scheme.tertiary;
      case 'pending':
      case 'in_progress':
        return scheme.secondary;
      case 'delivered':
        return scheme.primary;
      case 'revision_requested':
        return scheme.secondary;
      case 'rejected':
        return scheme.error;
      case 'done':
      case 'completed':
        return scheme.primary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _statusLabel() {
    switch (booking.status) {
      case 'confirmed':
        return localizations.bookingConfirmed;
      case 'pending':
        return localizations.bookingPending;
      case 'in_progress':
        return localizations.bookingInProgress;
      case 'delivered':
        return localizations.bookingDelivered;
      case 'revision_requested':
        return localizations.bookingRevisionRequested;
      case 'rejected':
        return localizations.bookingRejected;
      case 'done':
      case 'completed':
        return localizations.bookingCompleted;
      default:
        return booking.status.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusColor = _getStatusColor(context);
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
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.customerName, style: textTheme.titleMedium),
                      Text(booking.type, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: textTheme.labelSmall?.copyWith(
                      color: statusColor,
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
                Text(booking.time, style: textTheme.bodySmall),
                const SizedBox(width: 16),
                const Icon(Icons.payments, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${booking.price.toStringAsFixed(0)} IQD',
                  style: textTheme.bodySmall?.copyWith(
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
                        foregroundColor: scheme.error,
                        side: BorderSide(color: scheme.error),
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
