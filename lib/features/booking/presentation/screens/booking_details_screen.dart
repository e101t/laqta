import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/models/booking_model.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/presentation/mappers/booking_presentation_mapper.dart';
import 'package:laqta/features/chat/chat_dependencies.dart';
import 'package:laqta/features/deliveries/deliveries_dependencies.dart';
import 'package:laqta/features/deliveries/domain/entities/delivery.dart';
import 'package:laqta/features/deliveries/presentation/screens/delivery_upload_screen.dart';
import 'package:laqta/features/disputes/disputes_dependencies.dart';
import 'package:laqta/features/disputes/domain/entities/dispute.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/profile/domain/entities/user_profile.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';
import 'package:laqta/features/trust/trust_dependencies.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laqta/features/downloads/downloads_dependencies.dart';
import 'package:laqta/features/downloads/presentation/providers/download_provider.dart';
import 'package:laqta/features/downloads/presentation/screens/download_links_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final BookingModel? initialBooking;
  final String? currentUserIdOverride;
  final bool loadOnInit;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.initialBooking,
    this.currentUserIdOverride,
    this.loadOnInit = true,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  BookingModel? _booking;
  Delivery? _delivery;
  Dispute? _dispute;
  UserProfile? _photographerUser;
  UserProfile? _customerUser;
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    if (widget.currentUserIdOverride != null) {
      _currentUserId = widget.currentUserIdOverride!;
    }
    if (widget.initialBooking != null) {
      _booking = widget.initialBooking;
      _isLoading = false;
      return;
    }
    if (widget.loadOnInit) {
      _loadBookingDetails();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadBookingDetails() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      _currentUserId = userResult.valueOrNull?.id ?? '';

      final result = await BookingDependencies.getBookingById().call(
        widget.bookingId,
      );
      if (!mounted) return;
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError('Load booking failed');
      }
      _booking = BookingPresentationMapper.toModel(result.valueOrNull!);

      final photographerProfile = await ProfileDependencies.getUserProfile()
          .call(userId: _booking!.photographerId);
      if (!mounted) return;
      if (photographerProfile.isSuccess &&
          photographerProfile.valueOrNull != null) {
        _photographerUser = photographerProfile.valueOrNull;
      }

      final customerProfile = await ProfileDependencies.getUserProfile().call(
        userId: _booking!.customerId,
      );
      if (!mounted) return;
      if (customerProfile.isSuccess && customerProfile.valueOrNull != null) {
        _customerUser = customerProfile.valueOrNull;
      }

      final deliveryResult = await DeliveriesDependencies.getDeliveryByBooking()
          .call(widget.bookingId);
      if (!mounted) return;
      _delivery = deliveryResult.valueOrNull;

      final disputeResult = await DisputesDependencies.getDisputeByBooking()
          .call(widget.bookingId);
      if (!mounted) return;
      _dispute = disputeResult.valueOrNull;
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

  bool get _isPhotographer =>
      _booking != null && _booking!.photographerId == _currentUserId;

  bool get _isCustomer =>
      _booking != null && _booking!.customerId == _currentUserId;

  bool get _contactAllowed {
    if (_booking == null) return false;
    const allowed = {
      AppConstants.bookingConfirmed,
      AppConstants.bookingInProgress,
      AppConstants.bookingAwaitingDelivery,
      AppConstants.bookingDelivered,
      AppConstants.bookingRevisionRequested,
      AppConstants.bookingCompleted,
      AppConstants.bookingDone,
    };
    return allowed.contains(_booking!.status);
  }

  Color _getStatusColor(String status) {
    final scheme = Theme.of(context).colorScheme;
    switch (status) {
      case AppConstants.bookingConfirmed:
        return scheme.tertiary;
      case AppConstants.bookingInProgress:
        return scheme.secondary;
      case AppConstants.bookingAwaitingDelivery:
        return scheme.secondary;
      case AppConstants.bookingDelivered:
        return scheme.primary;
      case AppConstants.bookingRevisionRequested:
        return scheme.secondary;
      case AppConstants.bookingCompleted:
      case AppConstants.bookingDone:
        return scheme.primary;
      case AppConstants.bookingCanceled:
        return scheme.outline;
      case AppConstants.bookingDisputeOpen:
        return scheme.error;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  String _statusLabel(AppLocalizations localizations, String status) {
    switch (status) {
      case AppConstants.bookingConfirmed:
        return localizations.bookingConfirmed;
      case AppConstants.bookingInProgress:
        return localizations.bookingInProgress;
      case AppConstants.bookingAwaitingDelivery:
        return localizations.bookingAwaitingDelivery;
      case AppConstants.bookingDelivered:
        return localizations.bookingDelivered;
      case AppConstants.bookingRevisionRequested:
        return localizations.bookingRevisionRequested;
      case AppConstants.bookingCompleted:
      case AppConstants.bookingDone:
        return localizations.bookingCompleted;
      case AppConstants.bookingCanceled:
        return localizations.bookingCanceledMessage;
      case AppConstants.bookingDisputeOpen:
        return localizations.bookingDisputeOpen;
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Future<void> _startJob() async {
    if (_booking == null) return;

    final timeline = _booking!.timeline;
    final updates = {
      'status': AppConstants.bookingInProgress,
      'timeline': {
        'confirmedAt': timeline.confirmedAt != null
            ? Timestamp.fromDate(timeline.confirmedAt!)
            : Timestamp.fromDate(_booking!.createdAt),
        'inProgressAt': Timestamp.fromDate(DateTime.now()),
        'deliveredAt': timeline.deliveredAt != null
            ? Timestamp.fromDate(timeline.deliveredAt!)
            : null,
        'revisionRequestedAt': timeline.revisionRequestedAt != null
            ? Timestamp.fromDate(timeline.revisionRequestedAt!)
            : null,
        'completedAt': timeline.completedAt != null
            ? Timestamp.fromDate(timeline.completedAt!)
            : null,
        'canceledAt': timeline.canceledAt != null
            ? Timestamp.fromDate(timeline.canceledAt!)
            : null,
      },
    };

    await _updateBooking(updates);
    await _notifyUser(
      userId: _booking!.customerId,
      title: 'Booking started',
      body: 'The photographer marked the booking as in progress.',
      type: 'booking',
      data: {'bookingId': _booking!.id},
    );
  }

  Future<void> _openDeliveryUpload() async {
    if (_booking == null) return;

    final delivery = await Navigator.of(context).push<Delivery>(
      MaterialPageRoute(
        builder: (context) => DeliveryUploadScreen(
          bookingId: _booking!.id,
          photographerId: _booking!.photographerId,
          customerId: _booking!.customerId,
          existingDelivery: _delivery,
        ),
      ),
    );

    if (!mounted) return;
    if (delivery == null) return;

    final timeline = _booking!.timeline;
    final updates = {
      'status': AppConstants.bookingDelivered,
      'deliveryId': delivery.id,
      'timeline': {
        'confirmedAt': timeline.confirmedAt != null
            ? Timestamp.fromDate(timeline.confirmedAt!)
            : Timestamp.fromDate(_booking!.createdAt),
        'inProgressAt': timeline.inProgressAt != null
            ? Timestamp.fromDate(timeline.inProgressAt!)
            : null,
        'deliveredAt': Timestamp.fromDate(DateTime.now()),
        'revisionRequestedAt': timeline.revisionRequestedAt != null
            ? Timestamp.fromDate(timeline.revisionRequestedAt!)
            : null,
        'completedAt': timeline.completedAt != null
            ? Timestamp.fromDate(timeline.completedAt!)
            : null,
        'canceledAt': timeline.canceledAt != null
            ? Timestamp.fromDate(timeline.canceledAt!)
            : null,
      },
    };

    await _updateBooking(updates);
    await _notifyUser(
      userId: _booking!.customerId,
      title: 'Delivery submitted',
      body: 'Your photographer delivered files for your booking.',
      type: 'booking',
      data: {'bookingId': _booking!.id},
    );
  }

  Future<void> _acceptDelivery() async {
    if (_booking == null || _delivery == null) return;

    final updatedDelivery = _delivery!.copyWith(status: 'accepted');
    await DeliveriesDependencies.upsertDelivery().call(updatedDelivery);

    final timeline = _booking!.timeline;
    final updates = {
      'status': AppConstants.bookingCompleted,
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
        'completedAt': Timestamp.fromDate(DateTime.now()),
        'canceledAt': timeline.canceledAt != null
            ? Timestamp.fromDate(timeline.canceledAt!)
            : null,
      },
    };

    await _updateBooking(updates);
    await TrustDependencies.incrementCompletedBookings().call(
      bookingId: _booking!.id,
      photographerId: _booking!.photographerId,
    );
    await _updateRequestStatus('closed');
    await _notifyUser(
      userId: _booking!.photographerId,
      title: 'Booking completed',
      body: 'The client accepted the delivery.',
      type: 'booking',
      data: {'bookingId': _booking!.id},
    );

    if (mounted) {
      AppRouter.goToWriteReview(
        context,
        _booking!.id,
        _booking!.photographerId,
        _photographerUser?.name ?? AppLocalizations.of(context).photographer,
      );
    }
  }

  Future<void> _openDownloadLinks() async {
    if (_booking == null || _delivery == null) return;

    final fileReferences = [
      ..._delivery!.photoUrls,
      ..._delivery!.videoUrls,
      ..._delivery!.otherUrls,
    ];

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider(
          create: (_) => DownloadProvider(
            generateLinksUseCase: DownloadsDependencies.generateDownloadLinks(),
            extendLinkUseCase: DownloadsDependencies.extendDownloadLink(),
            getLinksUseCase: DownloadsDependencies.getDownloadLinks(),
          ),
          child: DownloadLinksScreen(
            bookingId: _booking!.id,
            photographerId: _booking!.photographerId,
            customerId: _booking!.customerId,
            fileIds: fileReferences,
            canManageLinks: _isPhotographer,
          ),
        ),
      ),
    );
    if (!mounted) return;
    await _loadBookingDetails();
  }

  Future<void> _launchPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _requestRevision() async {
    if (_booking == null || _delivery == null) return;
    final localizations = AppLocalizations.of(context);

    if (_booking!.revisionCount >= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.revisionLimitReached)),
      );
      return;
    }

    final noteController = TextEditingController();
    String? note;
    try {
      note = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.requestRevision),
          content: TextField(
            controller: noteController,
            decoration: InputDecoration(
              hintText: localizations.revisionDescribeChanges,
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, noteController.text.trim()),
              child: Text(localizations.submit),
            ),
          ],
        ),
      );
    } finally {
      noteController.dispose();
    }

    if (note == null || note.isEmpty) return;

    final updatedDelivery = _delivery!.copyWith(
      status: 'revision_requested',
      revisionNote: note,
    );
    await DeliveriesDependencies.upsertDelivery().call(updatedDelivery);

    final timeline = _booking!.timeline;
    final updates = {
      'status': AppConstants.bookingRevisionRequested,
      'revisionCount': _booking!.revisionCount + 1,
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
        'revisionRequestedAt': Timestamp.fromDate(DateTime.now()),
        'completedAt': timeline.completedAt != null
            ? Timestamp.fromDate(timeline.completedAt!)
            : null,
        'canceledAt': timeline.canceledAt != null
            ? Timestamp.fromDate(timeline.canceledAt!)
            : null,
      },
    };

    await _updateBooking(updates);
    await _notifyUser(
      userId: _booking!.photographerId,
      title: 'Revision requested',
      body: 'The client requested a revision on the delivery.',
      type: 'booking',
      data: {'bookingId': _booking!.id},
    );
  }

  Future<void> _openDispute() async {
    if (_booking == null || _dispute != null) return;
    final localizations = AppLocalizations.of(context);

    final reasonController = TextEditingController();
    final detailsController = TextEditingController();
    String reason = '';
    String details = '';
    bool? confirmed;
    try {
      confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.openDispute),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: localizations.reasonLabel,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(
                  hintText: localizations.detailsLabel,
                ),
                maxLines: 4,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(localizations.submit),
            ),
          ],
        ),
      );
      reason = reasonController.text.trim();
      details = detailsController.text.trim();
    } finally {
      reasonController.dispose();
      detailsController.dispose();
    }

    if (confirmed != true) return;

    final dispute = Dispute(
      id: '',
      bookingId: _booking!.id,
      requestId: _booking!.requestId,
      customerId: _booking!.customerId,
      photographerId: _booking!.photographerId,
      openedBy: _currentUserId,
      reason: reason,
      details: details,
      evidenceUrls: const [],
      status: 'open',
      resolution: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      closedAt: null,
      decidedBy: null,
    );

    final result = await DisputesDependencies.createDispute().call(dispute);
    if (!result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.disputeOpenFailed)),
        );
      }
      return;
    }

    await TrustDependencies.incrementDisputesCount().call(
      bookingId: _booking!.id,
      photographerId: _booking!.photographerId,
    );

    await _updateBooking({'status': AppConstants.bookingDisputeOpen});
    final otherUserId = _isCustomer
        ? _booking!.photographerId
        : _booking!.customerId;
    await _notifyUser(
      userId: otherUserId,
      title: 'Dispute opened',
      body: 'A dispute was opened for this booking.',
      type: 'system',
      data: {'bookingId': _booking!.id},
    );
  }

  Future<void> _cancelBooking() async {
    if (_booking == null) return;
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
            child: Text(localizations.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final timeline = _booking!.timeline;
    await _updateBooking({
      'status': AppConstants.bookingCanceled,
      'canceledBy': _currentUserId,
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
        'completedAt': timeline.completedAt != null
            ? Timestamp.fromDate(timeline.completedAt!)
            : null,
        'canceledAt': Timestamp.fromDate(DateTime.now()),
      },
    });

    if (_isPhotographer) {
      await TrustDependencies.incrementCanceledByPhotographer().call(
        bookingId: _booking!.id,
        photographerId: _booking!.photographerId,
      );
    }
    await _updateRequestStatus('closed');

    final otherUserId = _isCustomer
        ? _booking!.photographerId
        : _booking!.customerId;
    await _notifyUser(
      userId: otherUserId,
      title: 'Booking canceled',
      body: 'The booking was canceled.',
      type: 'booking',
      data: {'bookingId': _booking!.id},
    );
  }

  Future<void> _updateBooking(Map<String, dynamic> updates) async {
    final localizations = AppLocalizations.of(context);
    final result = await BookingDependencies.updateBooking().call(
      bookingId: widget.bookingId,
      updates: updates,
    );
    if (!result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.bookingUpdateFailed)),
        );
      }
      return;
    }
    await _loadBookingDetails();
  }

  Future<void> _openChat() async {
    if (_booking == null) return;

    final chatResult = await ChatDependencies.getOrCreateBookingChat().call(
      bookingId: _booking!.id,
      participants: [_booking!.customerId, _booking!.photographerId],
    );
    final chat = chatResult.valueOrNull;
    if (!chatResult.isSuccess || chat == null) return;

    final otherUserId = chat.participants.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => '',
    );
    String otherUserName = 'User';
    if (otherUserId.isNotEmpty) {
      final profileResult = await ProfileDependencies.getUserProfile().call(
        userId: otherUserId,
      );
      otherUserName = profileResult.valueOrNull?.name ?? 'User';
    }

    if (mounted) {
      AppRouter.goToChat(context, chat.id, otherUserName);
    }
  }

  Future<void> _notifyUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: userId,
        title: title,
        body: body,
        type: type,
        data: data,
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
    } catch (_) {
      // Notifications are best-effort.
    }
  }

  Future<void> _updateRequestStatus(String status) async {
    final requestId = _booking?.requestId;
    if (requestId == null || requestId.isEmpty) return;
    await RequestsDependencies.updateRequest().call(
      requestId: requestId,
      updates: {'status': status},
    );
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_booking == null) {
      return Scaffold(
        body: _hasError
            ? EmptyStates.error(onRetry: _loadBookingDetails)
            : EmptyState(
                icon: Icons.event_busy,
                title: localizations.bookingNotFound,
                message: localizations.bookingLoadError,
              ),
      );
    }

    final booking = _booking!;
    final statusColor = _getStatusColor(booking.status);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.bookingRoom),
        actions: [
          IconButton(icon: const Icon(Icons.message), onPressed: _openChat),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadBookingDetails,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BookingHeader(
              booking: booking,
              customer: _customerUser,
              photographer: _photographerUser,
            ),
            if (_isCustomer) ...[
              const SizedBox(height: 12),
              _ContactCard(
                photographer: _photographerUser,
                contactAllowed: _contactAllowed,
                onCall: () => _launchPhone(_photographerUser?.phone),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                _statusLabel(localizations, booking.status),
                style: textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _TimelineSection(timeline: booking.timeline),
            const SizedBox(height: 16),
            _BookingDetailsCard(booking: booking),
            if (booking.location.lat != null &&
                booking.location.lng != null) ...[
              const SizedBox(height: 12),
              _BookingLocationMap(
                booking: booking,
                photographer: _photographerUser,
              ),
              const SizedBox(height: 12),
            ],
            _DeliverySection(delivery: _delivery, onOpenFile: _openFile),
            if (_delivery != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _openDownloadLinks,
                icon: const Icon(Icons.download_done),
                label: Text(localizations.downloadLinks),
              ),
            ],
            const SizedBox(height: 16),
            _PolicyCard(
              items: [
                localizations.policyHighlightOne,
                localizations.policyHighlightTwo,
                localizations.policyHighlightThree,
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => AppRouter.goToBookingPolicies(context),
              child: Text(localizations.readFullTerms),
            ),
            if (_dispute != null) ...[
              const SizedBox(height: 16),
              _DisputeBanner(dispute: _dispute!),
            ],
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    if (_booking == null) return const SizedBox.shrink();

    final booking = _booking!;
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final buttons = <Widget>[];

    if (_isPhotographer) {
      if (booking.status == AppConstants.bookingConfirmed) {
        buttons.add(
          ElevatedButton(
            onPressed: _startJob,
            child: Text(localizations.startJob),
          ),
        );
      }
      if (booking.status == AppConstants.bookingInProgress ||
          booking.status == AppConstants.bookingAwaitingDelivery ||
          booking.status == AppConstants.bookingRevisionRequested) {
        buttons.add(
          ElevatedButton(
            onPressed: _openDeliveryUpload,
            child: Text(localizations.uploadDelivery),
          ),
        );
      }
    }

    if (_isCustomer) {
      if (booking.status == AppConstants.bookingDelivered) {
        buttons.add(
          ElevatedButton(
            onPressed: _acceptDelivery,
            child: Text(localizations.acceptDelivery),
          ),
        );
        if (booking.revisionCount < 1) {
          buttons.add(
            OutlinedButton(
              onPressed: _requestRevision,
              child: Text(localizations.requestRevision),
            ),
          );
        }
      }
    }

    if (booking.status != AppConstants.bookingCompleted &&
        booking.status != AppConstants.bookingCanceled &&
        booking.status != AppConstants.bookingDisputeOpen) {
      buttons.add(
        OutlinedButton(
          onPressed: _openDispute,
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error),
          ),
          child: Text(localizations.openDispute),
        ),
      );
    }

    if (_isCustomer &&
        (booking.status == AppConstants.bookingConfirmed ||
            booking.status == AppConstants.bookingInProgress)) {
      buttons.add(
        OutlinedButton(
          onPressed: _cancelBooking,
          style: OutlinedButton.styleFrom(
            foregroundColor: scheme.error,
            side: BorderSide(color: scheme.error),
          ),
          child: Text(localizations.cancelBooking),
        ),
      );
    }

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: buttons
          .map(
            (button) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: button,
            ),
          )
          .toList(),
    );
  }
}

class _BookingHeader extends StatelessWidget {
  final BookingModel booking;
  final UserProfile? customer;
  final UserProfile? photographer;

  const _BookingHeader({
    required this.booking,
    required this.customer,
    required this.photographer,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: scheme.primary.withValues(alpha: 0.12),
              child: Icon(Icons.camera_alt, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    photographer?.name ?? localizations.photographer,
                    style: textTheme.titleMedium,
                  ),
                  Text(
                    customer?.name ?? localizations.customer,
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final UserProfile? photographer;
  final bool contactAllowed;
  final VoidCallback onCall;

  const _ContactCard({
    required this.photographer,
    required this.contactAllowed,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final phone = photographer?.phone;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.phone, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contactAllowed
                        ? (phone ?? 'No phone number available')
                        : 'رقم الهاتف يظهر بعد تأكيد الحجز',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: contactAllowed
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (!contactAllowed)
                    Text(
                      'هذا جزء من سياسة الخصوصية لضمان التواصل داخل المنصة.',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            if (contactAllowed && phone != null)
              ElevatedButton(
                onPressed: onCall,
                style: ElevatedButton.styleFrom(
                  backgroundColor: scheme.primary,
                ),
                child: const Text('اتصال'),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingDetailsCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingDetailsCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _DetailRow(
              icon: Icons.calendar_today,
              label: localizations.dateLabel,
              value: booking.date,
            ),
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.access_time,
              label: localizations.timeLabel,
              value: booking.time,
            ),
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.camera_alt,
              label: localizations.typeLabel,
              value: booking.type,
            ),
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.timer,
              label: localizations.duration,
              value: '${booking.duration} ${localizations.minutes}',
            ),
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.location_on,
              label: localizations.locationLabel,
              value: booking.location.text ?? localizations.notSpecified,
            ),
            if (booking.notes != null) ...[
              const Divider(height: 24),
              _DetailRow(
                icon: Icons.note,
                label: localizations.notesLabel,
                value: booking.notes!,
              ),
            ],
            const Divider(height: 24),
            _DetailRow(
              icon: Icons.attach_money,
              label: localizations.priceLabel,
              value: '${booking.price.toStringAsFixed(0)} ${booking.currency}',
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: textTheme.bodyMedium?.copyWith(
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

class _BookingLocationMap extends StatelessWidget {
  final BookingModel booking;
  final UserProfile? photographer;

  const _BookingLocationMap({
    required this.booking,
    required this.photographer,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final lat = booking.location.lat;
    final lng = booking.location.lng;
    if (lat == null || lng == null) {
      return const SizedBox.shrink();
    }

    final markerPosition = LatLng(lat, lng);
    final governorate = _extractGovernorate(booking.location.text);
    final distanceLabel = _buildDistanceLabel(
      localizations,
      photographer?.governorate,
      governorate,
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: markerPosition,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('booking-location'),
                  position: markerPosition,
                ),
              },
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              scrollGesturesEnabled: false,
              myLocationButtonEnabled: false,
              onMapCreated: (_) {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.location.text ?? localizations.locationLabel,
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  distanceLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _buildDistanceLabel(
  AppLocalizations localizations,
  String? photographerGov,
  String? requestGov,
) {
  if (photographerGov == null) {
    return requestGov != null
        ? '${localizations.photographerInGov} $requestGov'
        : localizations.distanceUnavailable;
  }

  final distance = _estimateDistanceKm(requestGov, photographerGov);
  if (distance == null) {
    return '${localizations.photographerInGov} $photographerGov';
  }
  return '${localizations.photographerInGov} $photographerGov • ${localizations.estimatedDistance} ${distance.toStringAsFixed(0)} ${localizations.distanceUnit}';
}

double? _estimateDistanceKm(String? requestGov, String photographerGov) {
  if (requestGov == null) {
    return null;
  }
  return requestGov == photographerGov ? 6 : 28;
}

String? _extractGovernorate(String? text) {
  if (text == null) {
    return null;
  }
  final normalized = text.toLowerCase();
  for (final gov in AppConstants.iraqiGovernoratesAr) {
    if (normalized.contains(gov.toLowerCase())) {
      return gov;
    }
  }
  for (final gov in AppConstants.iraqiGovernoratesEn) {
    if (normalized.contains(gov.toLowerCase())) {
      return gov;
    }
  }
  return null;
}

class _DeliverySection extends StatelessWidget {
  final Delivery? delivery;
  final Future<void> Function(String) onOpenFile;

  const _DeliverySection({required this.delivery, required this.onOpenFile});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.delivery, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            if (delivery == null)
              Text(localizations.noDeliveryYet, style: textTheme.bodySmall)
            else ...[
              if (delivery!.photoUrls.isNotEmpty) ...[
                Text(localizations.photos, style: textTheme.bodySmall),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final url = delivery!.photoUrls[index];
                      return GestureDetector(
                        onTap: () => onOpenFile(url),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, _) => const SizedBox(width: 8),
                    itemCount: delivery!.photoUrls.length,
                  ),
                ),
              ],
              if (delivery!.videoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(localizations.videos, style: textTheme.bodySmall),
                const SizedBox(height: 4),
                Column(
                  children: delivery!.videoUrls
                      .map(
                        (url) => ListTile(
                          leading: const Icon(Icons.video_file),
                          title: Text(
                            url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => onOpenFile(url),
                        ),
                      )
                      .toList(),
                ),
              ],
              if (delivery!.note != null) ...[
                const SizedBox(height: 8),
                Text('${localizations.note}: ${delivery!.note}'),
              ],
              if (delivery!.revisionNote != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${localizations.revisionRequest}: ${delivery!.revisionNote}',
                  style: textTheme.bodySmall?.copyWith(color: scheme.secondary),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineSection extends StatelessWidget {
  final BookingTimeline timeline;

  const _TimelineSection({required this.timeline});

  String _format(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final entries = <Map<String, String>>[
      {
        'label': localizations.bookingConfirmed,
        'value': _format(timeline.confirmedAt),
      },
      {
        'label': localizations.bookingInProgress,
        'value': _format(timeline.inProgressAt),
      },
      {
        'label': localizations.bookingDelivered,
        'value': _format(timeline.deliveredAt),
      },
      {
        'label': localizations.bookingRevisionRequested,
        'value': _format(timeline.revisionRequestedAt),
      },
      {
        'label': localizations.bookingCompleted,
        'value': _format(timeline.completedAt),
      },
      {
        'label': localizations.bookingCanceledMessage,
        'value': _format(timeline.canceledAt),
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(localizations.timeline, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            ...entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(entry['label']!)),
                    Text(entry['value']!),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final List<String> items;

  const _PolicyCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.policyHighlightsTitle,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 18)),
                    Expanded(child: Text(item, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisputeBanner extends StatelessWidget {
  final Dispute dispute;

  const _DisputeBanner({required this.dispute});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.error),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: scheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${localizations.bookingDisputeOpen}: ${dispute.reason}',
              style: textTheme.bodyMedium?.copyWith(color: scheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
