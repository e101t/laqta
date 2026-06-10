import 'package:flutter/foundation.dart';
import 'package:laqta/core/logging/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/models/booking_model.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;

  final List<BookingModel> _activeBookings = [];
  final List<BookingModel> _pastBookings = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final result = await BookingDependencies.getMyBookings().call(
        userId: userId,
      );
      if (!result.isSuccess) {
        throw StateError('Load bookings failed');
      }
      final bookingEntities = result.valueOrNull ?? [];
      final bookings = bookingEntities
          .map(BookingPresentationMapper.toModel)
          .toList();

      // Separate active and past bookings
      final now = DateTime.now();
      _activeBookings.clear();
      _pastBookings.clear();

      for (final booking in bookings) {
        final bookingDateTime = DateTime.parse(
          '${booking.date} ${booking.time}',
        );
        final isPast =
            bookingDateTime.isBefore(now) ||
            booking.status == 'done' ||
            booking.status == 'completed' ||
            booking.status == 'canceled';

        if (isPast) {
          _pastBookings.add(booking);
        } else {
          _activeBookings.add(booking);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error loading bookings: $e');
      }
      _hasError = true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.cancelBooking),
        content: Text(localizations.bookingCancelPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.no),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await BookingDependencies.updateBookingStatus().call(
          bookingId: bookingId,
          status: 'canceled',
        );
        if (!result.isSuccess) {
          throw StateError('Cancel failed');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.bookingCancelSuccess)),
          );
          _loadBookings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations.bookingCancelFailed)),
          );
        }
      }
    }
  }

  Future<void> _navigateToChat(BookingModel booking) async {
    final localizations = AppLocalizations.of(context);
    try {
      // Get current user
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) return;

      final chatResult = await ChatDependencies.getOrCreateBookingChat().call(
        bookingId: booking.id,
        participants: [userId, booking.photographerId],
      );
      if (!chatResult.isSuccess || chatResult.valueOrNull == null) {
        throw StateError(
          chatResult.failureOrNull?.message ?? 'Failed to open chat',
        );
      }

      final chat = chatResult.valueOrNull!;
      final otherUserId = chat.participants.firstWhere(
        (id) => id != userId,
        orElse: () => '',
      );
      String otherUserName = 'Unknown';

      if (otherUserId.isNotEmpty) {
        final profileResult = await ProfileDependencies.getUserProfile().call(
          userId: otherUserId,
        );
        if (profileResult.isSuccess && profileResult.valueOrNull != null) {
          otherUserName = profileResult.valueOrNull!.name;
        }
      }

      final chatId = chat.id;

      // Navigate to chat
      if (mounted) {
        AppRouter.goToChat(context, chatId, otherUserName);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error navigating to chat: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(localizations.error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myBookings),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.active),
            Tab(text: localizations.past),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError && _activeBookings.isEmpty && _pastBookings.isEmpty
          ? EmptyStates.error(onRetry: _loadBookings)
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBookingsList(_activeBookings, isActive: true),
                  _buildBookingsList(_pastBookings, isActive: false),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingsList(
    List<BookingModel> bookings, {
    required bool isActive,
  }) {
    final localizations = AppLocalizations.of(context);
    if (bookings.isEmpty) {
      return EmptyState(
        icon: Icons.event_busy,
        title: localizations.noBookings,
        message: localizations.noBookingsMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(
          booking: booking,
          isActive: isActive,
          onCancel: () => _cancelBooking(booking.id),
          onChat: () => _navigateToChat(booking),
          onReview: (photographerName) {
            AppRouter.goToWriteReview(
              context,
              booking.id,
              booking.photographerId,
              photographerName,
            );
          },
        );
      },
    );
  }
}

class _BookingCard extends StatefulWidget {
  final BookingModel booking;
  final bool isActive;
  final VoidCallback onCancel;
  final VoidCallback onChat;
  final Function(String) onReview;

  const _BookingCard({
    required this.booking,
    required this.isActive,
    required this.onCancel,
    required this.onChat,
    required this.onReview,
  });

  @override
  State<_BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends State<_BookingCard> {
  UserProfile? _photographerUser;
  bool _isLoadingPhotographer = true;

  @override
  void initState() {
    super.initState();
    _loadPhotographer();
  }

  Future<void> _loadPhotographer() async {
    try {
      final result = await ProfileDependencies.getUserProfile().call(
        userId: widget.booking.photographerId,
      );
      if (result.isSuccess) {
        _photographerUser = result.valueOrNull;
      }

      setState(() => _isLoadingPhotographer = false);
    } catch (e) {
      setState(() => _isLoadingPhotographer = false);
      if (kDebugMode) {
        AppLogger.d('runtime', 'Error loading photographer: $e');
      }
    }
  }

  Color _getStatusColor() {
    final scheme = Theme.of(context).colorScheme;
    switch (widget.booking.status) {
      case 'confirmed':
        return scheme.tertiary;
      case 'pending':
        return scheme.secondary;
      case 'in_progress':
        return scheme.secondary;
      case 'delivered':
        return scheme.primary;
      case 'revision_requested':
        return scheme.secondary;
      case 'completed':
        return scheme.primary;
      case 'rejected':
        return scheme.error;
      case 'done':
        return scheme.primary;
      case 'canceled':
        return scheme.outline;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _localizedStatus(AppLocalizations localizations, String status) {
    switch (status) {
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
      case 'completed':
      case 'done':
        return localizations.bookingCompleted;
      case 'rejected':
        return localizations.bookingRejected;
      case 'canceled':
        return localizations.bookingCanceledMessage;
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final statusColor = _getStatusColor();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          AppRouter.goToBookingDetails(context, widget.booking.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: scheme.primary.withValues(alpha: 0.12),
                    child: Icon(Icons.person, color: scheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingPhotographer
                              ? localizations.loading
                              : _photographerUser?.name ??
                                    localizations.photographer,
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          widget.booking.type,
                          style: textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
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
                      _localizedStatus(localizations, widget.booking.status),
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
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.booking.date),
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.booking.time, style: textTheme.bodySmall),
                  const Spacer(),
                  Text(
                    '${widget.booking.price.toStringAsFixed(0)} ${widget.booking.currency}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              if (widget.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.booking.status != 'canceled' &&
                        widget.booking.status != 'completed' &&
                        widget.booking.status != 'done') ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onChat,
                          icon: const Icon(Icons.message, size: 16),
                          label: Text(localizations.chat),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.booking.status == 'pending' ||
                        widget.booking.status == 'confirmed' ||
                        widget.booking.status == 'in_progress') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.error,
                            side: BorderSide(color: scheme.error),
                          ),
                          child: Text(localizations.cancel),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (widget.booking.status == 'done' ||
                  widget.booking.status == 'completed') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onReview(
                      _photographerUser?.name ?? localizations.photographer,
                    ),
                    icon: const Icon(Icons.star, size: 16),
                    label: Text(localizations.leaveReview),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

