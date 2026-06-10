import 'dart:async';

import 'package:flutter/material.dart';
import 'package:laqta/core/constants/app_constants.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/backend_media_image.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/booking/booking_dependencies.dart';
import 'package:laqta/features/booking/domain/entities/booking.dart';
import 'package:laqta/features/notifications/domain/entities/notification_model.dart';
import 'package:laqta/features/notifications/notifications_dependencies.dart';
import 'package:laqta/features/offers/presentation/widgets/offer_filters_widget.dart';
import 'package:laqta/features/profile/profile_dependencies.dart';
import 'package:laqta/features/requests/domain/entities/photo_request.dart';
import 'package:laqta/features/requests/domain/entities/request_offer.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';
import 'package:laqta/features/requests/presentation/screens/create_request_screen.dart';
import 'package:laqta/features/trust/trust_dependencies.dart';
import 'package:laqta/features/trust/domain/entities/trust_stats.dart';

class RequestDetailsScreen extends StatefulWidget {
  final String requestId;

  const RequestDetailsScreen({super.key, required this.requestId});

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  PhotoRequest? _request;
  List<RequestOffer> _offers = [];
  List<RequestOffer> _displayedOffers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _currentUserId = '';
  final Map<String, _OfferMetrics> _offerMetrics = {};
  OfferFilterCriteria _selectedFilter = OfferFilterCriteria.priceLowToHigh;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      _currentUserId = userResult.valueOrNull?.id ?? '';

      final result = await RequestsDependencies.getRequestById().call(
        widget.requestId,
      );
      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError('Failed to load request');
      }

      _request = result.valueOrNull;
      _startCountdown();
      if (_isOwner) {
        await _loadOffers();
      }
    } catch (_) {
      _hasError = true;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  bool get _isOwner => _request != null && _currentUserId == _request!.clientId;

  bool get _canEdit =>
      _isOwner && _request != null && !_isLockedStatus(_request!.status);

  bool get _canCancel =>
      _isOwner &&
      _request != null &&
      _request!.status != 'canceled' &&
      _request!.status != 'closed' &&
      _request!.status != 'expired' &&
      _request!.status != 'offer_selected';

  bool _isLockedStatus(String status) {
    return status == 'offer_selected' ||
        status == 'closed' ||
        status == 'canceled' ||
        status == 'expired';
  }

  Future<void> _loadOffers() async {
    if (_request == null) return;

    final result = await RequestsDependencies.getOffersForRequest().call(
      _request!.id,
    );
    if (!result.isSuccess) {
      return;
    }

    _offers = result.valueOrNull ?? <RequestOffer>[];
    _displayedOffers = List<RequestOffer>.from(_offers);
    _offerMetrics.clear();
    await _cacheOfferMetrics(_offers);
    _applyOfferFilter();
  }

  Future<void> _editRequest() async {
    if (_request == null) return;
    final wasUpdated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (modalContext) => CreateRequestScreen(
          initialRequest: _request,
          onRequestSubmitted: (_) => Navigator.of(modalContext).pop(true),
        ),
      ),
    );
    if (wasUpdated == true) {
      await _loadRequest();
    }
  }

  Future<void> _cancelRequest() async {
    if (_request == null) return;
    final localizations = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.cancelRequest),
        content: Text(localizations.cancelRequestPrompt),
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

    final result = await RequestsDependencies.updateRequest().call(
      requestId: _request!.id,
      updates: {'status': 'canceled'},
    );
    if (!result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.requestCancelFailed)),
        );
      }
      return;
    }
    await _notifyOfferPhotographers();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(localizations.requestCanceled)));
    }
    await _loadRequest();
  }

  Future<void> _notifyOfferPhotographers() async {
    if (_request == null) return;
    var offers = _offers;
    if (offers.isEmpty) {
      final result = await RequestsDependencies.getOffersForRequest().call(
        _request!.id,
      );
      offers = result.valueOrNull ?? <RequestOffer>[];
    }
    if (offers.isEmpty) return;

    final photographerIds = offers.map((offer) => offer.photographerId).toSet();
    for (final id in photographerIds) {
      final notification = NotificationModel(
        notificationId: '',
        userId: id,
        title: 'Request canceled',
        body: 'A request you offered on was canceled.',
        type: 'request',
        data: {'requestId': _request!.id},
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
    }
  }

  Future<void> _acceptOffer(RequestOffer offer) async {
    if (_request == null || _currentUserId.isEmpty) return;
    final localizations = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.acceptOffer),
        content: Text(localizations.acceptOfferPrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.accept),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final bookingId = BookingDependencies.generateBookingId().call();
      final booking = _buildBookingFrom(offer, bookingId);
      final result = await RequestsDependencies.acceptOffer().call(
        request: _request!,
        offer: offer,
        booking: booking,
      );
      if (!result.isSuccess) {
        throw StateError(
          result.failureOrNull?.message ?? 'Failed to accept offer',
        );
      }
      await _notifyPhotographer(offer, bookingId);

      if (mounted) {
        AppRouter.goToBookingDetails(context, bookingId);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _mapAcceptOfferError(
                error is StateError ? error.message : null,
                localizations,
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapAcceptOfferError(String? message, AppLocalizations localizations) {
    switch (message) {
      case "This offer is below the photographer's minimum booking price.":
        return _localizedText(
          ar: 'هذا العرض أقل من الحد الأدنى لسعر هذا المصور.',
          en: message!,
        );
      case 'This photographer does not accept same-day bookings.':
        return _localizedText(
          ar: 'هذا المصور لا يقبل الحجوزات في نفس اليوم.',
          en: message!,
        );
      case 'This photographer is unavailable on the selected day.':
        return _localizedText(
          ar: 'هذا المصور غير متاح في اليوم المحدد.',
          en: message!,
        );
      case "The selected time is outside the photographer's working hours.":
        return _localizedText(
          ar: 'الوقت المحدد خارج ساعات عمل المصور.',
          en: message!,
        );
      case 'This photographer already has another booking at that time.':
        return _localizedText(
          ar: 'لدى هذا المصور حجز آخر في هذا الوقت.',
          en: message!,
        );
      default:
        return localizations.acceptOfferFailed;
    }
  }

  String _localizedText({required String ar, required String en}) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'ar' ? ar : en;
  }

  Future<void> _notifyPhotographer(RequestOffer offer, String bookingId) async {
    try {
      final notification = NotificationModel(
        notificationId: '',
        userId: offer.photographerId,
        title: 'Offer accepted',
        body: 'Your offer was accepted. The booking is awaiting payment.',
        type: 'booking',
        data: {
          'requestId': offer.requestId,
          'offerId': offer.id,
          'bookingId': bookingId,
        },
        createdAt: DateTime.now(),
      );
      await NotificationsDependencies.createNotification().call(notification);
    } catch (_) {
      // Notifications are best-effort.
    }
  }

  Booking _buildBookingFrom(RequestOffer offer, String bookingId) {
    final request = _request!;
    return Booking(
      id: bookingId,
      customerId: request.clientId,
      photographerId: offer.photographerId,
      requestId: request.id,
      offerId: offer.id,
      date: request.date,
      time: request.time,
      duration: request.durationHours * 60,
      type: request.type,
      price: offer.price,
      currency: offer.currency,
      status: AppConstants.bookingPending,
      payment: const BookingPayment(status: AppConstants.paymentPending),
      location: BookingLocation(
        lat: request.latitude,
        lng: request.longitude,
        text: request.locationLabel ?? request.address ?? request.governorate,
      ),
      deliverables: BookingDeliverables(
        photosCount: offer.deliverables.photosCount,
        videoMinutes: offer.deliverables.videoMinutes,
        includesEditing: offer.deliverables.includesEditing,
        includesVideo: offer.deliverables.includesVideo,
        notes: offer.deliverables.notes,
      ),
      notes: request.notes,
      chatId: null,
      deliveryId: null,
      disputeId: null,
      revisionCount: 0,
      canceledBy: null,
      timeline: const BookingTimeline(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void _handleFilterChanged(OfferFilterCriteria filter) {
    if (_selectedFilter == filter) return;
    setState(() => _selectedFilter = filter);
    _applyOfferFilter();
  }

  Future<void> _cacheOfferMetrics(List<RequestOffer> offers) async {
    final metrics = await Future.wait(offers.map(_buildOfferMetrics));
    for (final metric in metrics) {
      _offerMetrics[metric.offerId] = metric;
    }
  }

  Future<_OfferMetrics> _buildOfferMetrics(RequestOffer offer) async {
    final trustResult = await TrustDependencies.getTrustStats().call(
      offer.photographerId,
    );
    final profileResult = await ProfileDependencies.getUserProfile().call(
      userId: offer.photographerId,
    );
    return _OfferMetrics(
      offerId: offer.id,
      trustScore: _deriveTrustScore(trustResult.valueOrNull),
      distanceKm: _estimateDistanceKm(
        _request?.governorate,
        profileResult.valueOrNull?.governorate,
      ),
    );
  }

  List<OfferForSort> _toSortableOffers() {
    return _offers
        .map(
          (offer) => OfferForSort(
            offerId: offer.id,
            photographerId: offer.photographerId,
            price: offer.price,
            trustScore: _offerMetrics[offer.id]?.trustScore ?? 50,
            deliveryDays: offer.deliveryDays,
            distanceKm: _offerMetrics[offer.id]?.distanceKm ?? 30,
          ),
        )
        .toList();
  }

  void _applyOfferFilter() {
    if (_offers.isEmpty) {
      if (mounted) {
        setState(() => _displayedOffers = []);
      }
      return;
    }

    final sorted = _selectedFilter.sortOffers(_toSortableOffers());
    final sortedOffers = sorted
        .map(
          (item) => _offers.firstWhere(
            (offer) => offer.id == item.offerId,
            orElse: () => _offers.first,
          ),
        )
        .toList();

    if (mounted) {
      setState(() => _displayedOffers = sortedOffers);
    }
  }

  double _estimateDistanceKm(String? requestGov, String? photographerGov) {
    if (requestGov == null || photographerGov == null) {
      return 40;
    }
    return requestGov == photographerGov ? 4 : 30;
  }

  double _deriveTrustScore(TrustStats? stats) {
    if (stats == null || stats.reviewCount == 0) {
      return 55;
    }
    final average =
        (stats.avgQuality +
            stats.avgCommunication +
            stats.avgOnTime +
            stats.avgDelivery) /
        4;
    return (average / 5) * 100;
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (_request?.expiresAt == null) return;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  String _countdownLabel() {
    final expiresAt = _request?.expiresAt;
    if (expiresAt == null) {
      return AppLocalizations.of(context).noDeadline;
    }
    final now = DateTime.now();
    if (now.isAfter(expiresAt)) {
      return AppLocalizations.of(context).requestStatusClosed;
    }
    final diff = expiresAt.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    final parts = <String>[];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    parts.add('${seconds}s');
    return parts.join(' ');
  }

  Widget _buildCountdownSection() {
    final expiresAt = _request?.expiresAt;
    if (expiresAt == null) return const SizedBox.shrink();
    final isExpired = DateTime.now().isAfter(expiresAt);
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isExpired
              ? localizations.offersClosed
              : localizations.receivingOffers,
          style: textTheme.bodyMedium,
        ),
        Text(
          isExpired ? localizations.requestStatusClosed : _countdownLabel(),
          style: textTheme.bodySmall?.copyWith(
            color: isExpired ? scheme.error : scheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_isLoading) {
      return const Scaffold(body: LoadingIndicator());
    }

    if (_request == null) {
      return Scaffold(
        body: _hasError
            ? EmptyStates.error(onRetry: _loadRequest)
            : EmptyState(
                icon: Icons.photo_camera_outlined,
                title: localizations.requestNotFound,
                message: localizations.requestLoadError,
              ),
      );
    }

    final request = _request!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.requestDetails)),
      floatingActionButton: !_isOwner
          ? FloatingActionButton.extended(
              onPressed: () => AppRouter.goToOfferSubmit(context, request.id),
              label: Text(localizations.sendOffer),
              icon: const Icon(Icons.send),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadRequest,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RequestSummaryCard(request: request),
            if (_canEdit || _canCancel) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_canEdit)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _editRequest,
                        icon: const Icon(Icons.edit),
                        label: Text(localizations.editRequest),
                      ),
                    ),
                  if (_canEdit && _canCancel) const SizedBox(width: 12),
                  if (_canCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _cancelRequest,
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(localizations.cancelRequest),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (_isOwner) ...[
              Text(
                localizations.offersSection,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              if (_request?.expiresAt != null) ...[
                _buildCountdownSection(),
                const SizedBox(height: 8),
              ],
              if (_offers.isNotEmpty) ...[
                OfferFiltersWidget(
                  currentFilter: _selectedFilter,
                  onFilterChanged: _handleFilterChanged,
                ),
                const SizedBox(height: 12),
              ],
              if (_displayedOffers.isEmpty)
                EmptyState(
                  icon: Icons.local_offer_outlined,
                  title: localizations.noOffersYet,
                  message: localizations.offersComingSoon,
                )
              else
                Column(
                  children: _displayedOffers
                      .map(
                        (offer) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OfferCard(
                            offer: offer,
                            onAccept: () => _acceptOffer(offer),
                          ),
                        ),
                      )
                      .toList(),
                ),
            ],
            if (!_isOwner) ...[
              const SizedBox(height: 16),
              Text(
                localizations.sendOfferPrompt,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestSummaryCard extends StatelessWidget {
  final PhotoRequest request;

  const _RequestSummaryCard({required this.request});

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
            Text(request.type, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            _InfoRow(label: localizations.dateLabel, value: request.date),
            _InfoRow(label: localizations.timeLabel, value: request.time),
            _InfoRow(
              label: localizations.locationLabel,
              value: request.governorate,
            ),
            if (request.address != null)
              _InfoRow(
                label: localizations.addressLabel,
                value: request.address!,
              ),
            _InfoRow(
              label: localizations.duration,
              value: '${request.durationHours} ${localizations.hours}',
            ),
            if (request.budgetMin != null || request.budgetMax != null)
              _InfoRow(
                label: localizations.budget,
                value: _formatBudget(request, localizations),
              ),
            if (request.style != null)
              _InfoRow(label: localizations.styleLabel, value: request.style!),
            if (request.deliverables.photosCount != null)
              _InfoRow(
                label: localizations.photos,
                value: '${request.deliverables.photosCount}',
              ),
            if (request.deliverables.videoMinutes != null)
              _InfoRow(
                label: localizations.videos,
                value:
                    '${request.deliverables.videoMinutes} ${localizations.minutes}',
              ),
            if (request.deliverables.includesVideo ||
                request.deliverables.includesEditing)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (request.deliverables.includesVideo)
                      _TagChip(label: localizations.includesVideo),
                    if (request.deliverables.includesEditing)
                      _TagChip(label: localizations.includesEditing),
                  ],
                ),
              ),
            if (request.notes != null)
              _InfoRow(label: localizations.notesLabel, value: request.notes!),
            if (request.latitude != null && request.longitude != null)
              _InfoRow(
                label: localizations.mapLabel,
                value:
                    request.locationLabel ??
                    'Lat ${request.latitude!.toStringAsFixed(4)}, '
                        'Lng ${request.longitude!.toStringAsFixed(4)}',
              ),
            if (request.referenceImages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(localizations.references, style: textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final url = request.referenceImages[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackendMediaImage(
                        url: url,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  },
                  separatorBuilder: (context, _) => const SizedBox(width: 8),
                  itemCount: request.referenceImages.length,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBudget(PhotoRequest request, AppLocalizations localizations) {
    final min = request.budgetMin;
    final max = request.budgetMax;
    if (min != null && max != null) {
      return '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} ${AppConstants.currencyIQD}';
    }
    if (min != null) {
      return '${localizations.budgetFrom} ${min.toStringAsFixed(0)} ${AppConstants.currencyIQD}';
    }
    if (max != null) {
      return '${localizations.budgetUpTo} ${max.toStringAsFixed(0)} ${AppConstants.currencyIQD}';
    }
    return '-';
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

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
      child: Text(label, style: textTheme.labelSmall),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: textTheme.labelSmall)),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final RequestOffer offer;
  final VoidCallback onAccept;

  const OfferCard({super.key, required this.offer, required this.onAccept});

  Future<String> _resolvePhotographerName() async {
    final result = await ProfileDependencies.getUserProfile().call(
      userId: offer.photographerId,
    );
    return result.valueOrNull?.name ?? '';
  }

  Future<String> _resolveTrustLabel() async {
    final result = await TrustDependencies.getTrustStats().call(
      offer.photographerId,
    );
    final stats = result.valueOrNull;
    if (stats == null || stats.reviewCount == 0) {
      return '';
    }

    final average =
        (stats.avgQuality +
            stats.avgCommunication +
            stats.avgOnTime +
            stats.avgDelivery) /
        4;
    if (average >= 4.2) return 'high';
    if (average >= 3.2) return 'medium';
    return 'low';
  }

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
            FutureBuilder<String>(
              future: _resolvePhotographerName(),
              builder: (context, snapshot) {
                final name = snapshot.data;
                final displayName = (name == null || name.isEmpty)
                    ? localizations.photographer
                    : name;
                return Text(displayName, style: textTheme.titleMedium);
              },
            ),
            const SizedBox(height: 6),
            FutureBuilder<String>(
              future: _resolveTrustLabel(),
              builder: (context, snapshot) {
                final raw = snapshot.data;
                final trustLabel = switch (raw) {
                  'high' => localizations.trustLevelHigh,
                  'medium' => localizations.trustLevelMedium,
                  'low' => localizations.trustLevelLow,
                  _ => localizations.trustLevelNew,
                };
                return Text(
                  '${localizations.trustScore}: $trustLabel',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${offer.price.toStringAsFixed(0)} ${offer.currency}',
              style: textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${localizations.deliveryInDays} ${offer.deliveryDays} ${localizations.days}',
            ),
            if (offer.notes != null) ...[
              const SizedBox(height: 8),
              Text(offer.notes!, style: textTheme.bodySmall),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onAccept,
                child: Text(localizations.acceptOffer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferMetrics {
  final String offerId;
  final double trustScore;
  final double distanceKm;

  const _OfferMetrics({
    required this.offerId,
    required this.trustScore,
    required this.distanceKm,
  });
}
