import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/booking_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:luqta/features/chat/chat_dependencies.dart';
import 'package:luqta/features/profile/domain/entities/user_profile.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';

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
            booking.status == 'canceled';

        if (isPast) {
          _pastBookings.add(booking);
        } else {
          _activeBookings.add(booking);
        }
      }
    } catch (e) {
      debugPrint('Error loading bookings: $e');
      _hasError = true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
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
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
          _loadBookings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to cancel booking: $e')),
          );
        }
      }
    }
  }

  Future<void> _navigateToChat(BookingModel booking) async {
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
      debugPrint('Error navigating to chat: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to open chat')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(localizations.myBookings),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Past'),
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
    if (bookings.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'No Bookings',
        message: 'You have no bookings yet',
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
      debugPrint('Error loading photographer: $e');
    }
  }

  Color _getStatusColor() {
    switch (widget.booking.status) {
      case 'confirmed':
        return AppColors.confirmed;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
        return AppColors.rejected;
      case 'done':
        return AppColors.done;
      case 'canceled':
        return AppColors.canceled;
      default:
        return AppColors.textSecondary;
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
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoadingPhotographer
                              ? 'Loading...'
                              : _photographerUser?.name ??
                                    'Unknown Photographer',
                          style: AppTypography.h4,
                        ),
                        Text(
                          widget.booking.type,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
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
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _getStatusColor()),
                    ),
                    child: Text(
                      widget.booking.status.toUpperCase(),
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
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.booking.date),
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.access_time, size: 16),
                  const SizedBox(width: 4),
                  Text(widget.booking.time, style: AppTypography.bodySmall),
                  const Spacer(),
                  Text(
                    '${widget.booking.price.toStringAsFixed(0)} ${widget.booking.currency}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              // Action Buttons
              if (widget.isActive) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (widget.booking.status == 'confirmed' ||
                        widget.booking.status == 'pending') ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onChat,
                          icon: const Icon(Icons.message, size: 16),
                          label: const Text('Chat'),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (widget.booking.status == 'pending' ||
                        widget.booking.status == 'confirmed') ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.error,
                            side: const BorderSide(color: AppColors.error),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (widget.booking.status == 'done') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => widget.onReview(
                      _photographerUser?.name ?? 'Unknown Photographer',
                    ),
                    icon: const Icon(Icons.star, size: 16),
                    label: const Text('Leave Review'),
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
