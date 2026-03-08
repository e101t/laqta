import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_constants.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/models/booking_model.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/booking/booking_dependencies.dart';
import 'package:luqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:luqta/features/disputes/disputes_dependencies.dart';
import 'package:luqta/features/disputes/domain/entities/dispute.dart';

class AdminDisputeDetailsScreen extends StatefulWidget {
  final Dispute dispute;

  const AdminDisputeDetailsScreen({super.key, required this.dispute});

  @override
  State<AdminDisputeDetailsScreen> createState() =>
      _AdminDisputeDetailsScreenState();
}

class _AdminDisputeDetailsScreenState extends State<AdminDisputeDetailsScreen> {
  final TextEditingController _resolutionController = TextEditingController();
  BookingModel? _booking;
  bool _isLoading = true;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  @override
  void dispose() {
    _resolutionController.dispose();
    super.dispose();
  }

  Future<void> _loadBooking() async {
    setState(() => _isLoading = true);
    try {
      final result = await BookingDependencies.getBookingById().call(
        widget.dispute.bookingId,
      );
      if (result.isSuccess && result.valueOrNull != null) {
        _booking = BookingPresentationMapper.toModel(result.valueOrNull!);
      }
    } catch (_) {
      // Ignore booking load errors; dispute details still show.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resolveDispute({
    required String resolutionCode,
    required String bookingStatus,
  }) async {
    if (_isResolving) return;
    setState(() => _isResolving = true);

    final adminResult = await AuthDependencies.getCurrentUser().call();
    final adminId = adminResult.valueOrNull?.id;
    final now = DateTime.now();
    final note = _resolutionController.text.trim();
    final resolution = note.isEmpty ? resolutionCode : '$resolutionCode: $note';

    final updatedDispute = widget.dispute.copyWith(
      status: 'resolved',
      resolution: resolution,
      updatedAt: now,
      closedAt: now,
      decidedBy: adminId,
    );
    final disputeResult =
        await DisputesDependencies.updateDispute().call(updatedDispute);

    if (!disputeResult.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).disputeResolveFailed)),
        );
      }
      setState(() => _isResolving = false);
      return;
    }

    if (_booking != null) {
      final timeline = _booking!.timeline;
      final updates = {
        'status': bookingStatus,
        'disputeId': widget.dispute.id,
        'timeline': {
          'confirmedAt': timeline.confirmedAt != null
              ? Timestamp.fromDate(timeline.confirmedAt!)
              : Timestamp.fromDate(_booking!.createdAt),
          'inProgressAt': timeline.inProgressAt != null
              ? Timestamp.fromDate(timeline.inProgressAt!)
              : null,
          'deliveredAt': timeline.deliveredAt != null
              ? Timestamp.fromDate(timeline.deliveredAt!)
              : null,
          'revisionRequestedAt': timeline.revisionRequestedAt != null
              ? Timestamp.fromDate(timeline.revisionRequestedAt!)
              : null,
          'completedAt': bookingStatus == AppConstants.bookingCompleted
              ? Timestamp.fromDate(now)
              : (timeline.completedAt != null
                  ? Timestamp.fromDate(timeline.completedAt!)
                  : null),
          'canceledAt': bookingStatus == AppConstants.bookingCanceled
              ? Timestamp.fromDate(now)
              : (timeline.canceledAt != null
                  ? Timestamp.fromDate(timeline.canceledAt!)
                  : null),
        },
      };
      await BookingDependencies.updateBooking().call(
        bookingId: _booking!.id,
        updates: updates,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).disputeResolved)),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final dispute = widget.dispute;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.disputeDetails)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dispute.reason,
                          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text('${localizations.bookingSummary}: ${dispute.bookingId}'),
                        const SizedBox(height: 8),
                        Text('${localizations.openedByLabel}: ${dispute.openedBy}'),
                        const SizedBox(height: 8),
                        Text(dispute.details),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_booking != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.bookingSummary,
                            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text('${localizations.typeLabel}: ${_booking!.type}'),
                          Text('${localizations.dateLabel}: ${_booking!.date} ${_booking!.time}'),
                          Text('${localizations.statusLabel}: ${_booking!.status}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _resolutionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: localizations.resolutionNote,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveDispute(
                            resolutionCode: 'release_to_photographer',
                            bookingStatus: AppConstants.bookingCompleted,
                          ),
                  child: Text(localizations.resolveRelease),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveDispute(
                            resolutionCode: 'refund_full',
                            bookingStatus: AppConstants.bookingCanceled,
                          ),
                  child: Text(localizations.resolveRefund),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isResolving
                      ? null
                      : () => _resolveDispute(
                            resolutionCode: 'refund_partial',
                            bookingStatus: AppConstants.bookingCompleted,
                          ),
                  child: Text(localizations.resolvePartial),
                ),
              ],
            ),
    );
  }
}
