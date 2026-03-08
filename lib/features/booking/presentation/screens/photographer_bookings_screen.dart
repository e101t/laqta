import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/dashboard/dashboard_dependencies.dart';
import 'package:luqta/features/dashboard/domain/entities/dashboard_booking.dart';

class PhotographerBookingsScreen extends StatefulWidget {
  const PhotographerBookingsScreen({super.key});

  @override
  State<PhotographerBookingsScreen> createState() =>
      _PhotographerBookingsScreenState();
}

class _PhotographerBookingsScreenState extends State<PhotographerBookingsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  final List<DashboardBooking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing user');
      }

      final result = await DashboardDependencies.getPhotographerBookings().call(
        photographerId: userId,
      );
      if (!result.isSuccess) {
        throw StateError('Failed to load bookings');
      }

      _bookings
        ..clear()
        ..addAll(result.valueOrNull ?? <DashboardBooking>[]);

      setState(() => _isLoading = false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load photographer bookings: $e');
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _statusColor(ColorScheme scheme, String status) {
    switch (status) {
      case 'confirmed':
        return scheme.tertiary;
      case 'in_progress':
        return scheme.secondary;
      case 'delivered':
        return scheme.primary;
      case 'revision_requested':
        return scheme.secondary;
      case 'completed':
      case 'done':
        return scheme.primary;
      case 'canceled':
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _statusLabel(AppLocalizations localizations, String status) {
    switch (status) {
      case 'confirmed':
        return localizations.bookingConfirmed;
      case 'in_progress':
        return localizations.bookingInProgress;
      case 'delivered':
        return localizations.bookingDelivered;
      case 'revision_requested':
        return localizations.bookingRevisionRequested;
      case 'completed':
      case 'done':
        return localizations.bookingCompleted;
      case 'canceled':
        return localizations.bookingCanceledMessage;
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.myBookings)),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError
          ? EmptyStates.error(onRetry: _loadBookings)
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? EmptyState(
                      icon: Icons.event_busy,
                      title: localizations.noBookings,
                      message: localizations.noBookingsMessage,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final booking = _bookings[index];
                        final color = _statusColor(scheme, booking.status);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(booking.customerName),
                            subtitle: Text(
                              '${booking.type} \n${booking.date.day}/${booking.date.month}/${booking.date.year} ${booking.time}',
                            ),
                            isThreeLine: true,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _statusLabel(localizations, booking.status),
                                style: textTheme.labelSmall?.copyWith(
                                  color: color,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () => AppRouter.goToBookingDetails(
                              context,
                              booking.id,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
