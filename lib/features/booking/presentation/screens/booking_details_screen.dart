import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/constants/app_theme.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/booking_model.dart';
import 'package:luqta/core/models/photographer_model.dart';
import 'package:luqta/core/models/user_model.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:luqta/features/photographer/photographer_dependencies.dart';
import 'package:luqta/features/photographer/presentation/mappers/photographer_presentation_mapper.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  BookingModel? _booking;
  PhotographerModel? _photographer;
  UserModel? _photographerUser;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBookingDetails();
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await BookingDependencies.getBookingById().call(
        widget.bookingId,
      );
      if (!result.isSuccess) {
        throw StateError('Load booking failed');
      }
      final bookingEntity = result.valueOrNull;
      if (bookingEntity != null) {
        _booking = BookingPresentationMapper.toModel(bookingEntity);

        final photographerResult =
            await PhotographerDependencies.getPhotographerProfile().call(
              photographerId: _booking!.photographerId,
            );
        if (photographerResult.isSuccess &&
            photographerResult.valueOrNull != null) {
          final bundle = photographerResult.valueOrNull!;
          _photographer = PhotographerPresentationMapper.toPhotographerModel(
            bundle.photographer,
          );
          _photographerUser = PhotographerPresentationMapper.toUserModel(
            bundle.user,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading booking details: $e');
      }
      _hasError = true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor() {
    switch (_booking?.status) {
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

  void _showCancelConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking() async {
    try {
      final result = await BookingDependencies.updateBookingStatus().call(
        bookingId: widget.bookingId,
        status: 'canceled',
      );
      if (!result.isSuccess) {
        throw StateError('Cancel failed');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking canceled successfully')),
        );
        Navigator.pop(context); // Go back to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error canceling booking')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const LoadingIndicator(),
      );
    }

    if (_booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: _hasError
            ? EmptyStates.error(onRetry: _loadBookingDetails)
            : const EmptyState(
                icon: Icons.event_busy,
                title: 'Booking Not Found',
                message: 'The booking details could not be loaded.',
              ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Booking Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photographer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _photographerUser?.name ?? 'Unknown Photographer',
                            style: AppTypography.h4,
                          ),
                          Text(
                            _photographer?.specialties.join(', ') ??
                                'No specialties',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor()),
              ),
              child: Text(
                _booking!.status.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  color: _getStatusColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Booking Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Date',
                      _formatDate(_booking!.date),
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(Icons.access_time, 'Time', _booking!.time),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.camera_alt,
                      'Session Type',
                      _booking!.type,
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.timer,
                      'Duration',
                      '${_booking!.duration} minutes',
                    ),
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.location_on,
                      'Location',
                      _booking!.location.text ?? 'No location specified',
                    ),
                    if (_booking!.notes != null) ...[
                      const Divider(height: 24),
                      _buildDetailRow(Icons.note, 'Notes', _booking!.notes!),
                    ],
                    const Divider(height: 24),
                    _buildDetailRow(
                      Icons.attach_money,
                      'Price',
                      '${_booking!.price.toStringAsFixed(0)} ${_booking!.currency}',
                    ),
                  ],
                ),
              ),
            ),

            // Action Buttons (if applicable)
            if (_booking!.status == 'confirmed' ||
                _booking!.status == 'pending') ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final userResult =
                            await AuthDependencies.getCurrentUser().call();
                        final userId = userResult.valueOrNull?.id;
                        if (userId == null || userId.isEmpty) return;
                        if (!context.mounted) return;
                        final userIds = [userId, _booking!.photographerId];
                        userIds.sort();
                        final chatId = userIds.join('_');
                        final otherUserName =
                            _photographerUser?.name ?? 'Photographer';
                        AppRouter.goToChat(context, chatId, otherUserName);
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Chat'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Add payment button if status is pending and payment status is not succeeded
                  if (_booking!.status == 'pending' &&
                      _booking!.payment.status != 'succeeded') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (!AppConstants.enablePayments) {
                            final localizations = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  localizations.paymentsUnavailable,
                                ),
                              ),
                            );
                            return;
                          }
                          AppRouter.goToPayment(
                            context,
                            _booking!.id,
                            _booking!.price,
                            _photographerUser?.name ?? 'Photographer',
                            _booking!.type,
                          );
                        },
                        icon: const Icon(Icons.payment, size: 16),
                        label: const Text('Pay Now'),
                      ),
                    ),
                  ] else if (_booking!.status == 'pending' ||
                      _booking!.status == 'confirmed') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showCancelConfirmation();
                        },
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
            ] else if (_booking!.status == 'done') ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppRouter.goToWriteReview(
                      context,
                      widget.bookingId,
                      _booking!.photographerId,
                      _photographerUser?.name ?? 'Photographer',
                    );
                  },
                  icon: const Icon(Icons.star, size: 16),
                  label: const Text('Leave Review'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.caption),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
