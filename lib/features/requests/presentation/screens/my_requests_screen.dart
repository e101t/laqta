import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/app/router/app_router.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/core/widgets/loading_widgets.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';
import 'package:laqta/features/requests/domain/entities/photo_request.dart';
import 'package:laqta/features/requests/requests_dependencies.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasError = false;
  final List<PhotoRequest> _draftRequests = [];
  final List<PhotoRequest> _activeRequests = [];
  final List<PhotoRequest> _closedRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        return;
      }

      final result = await RequestsDependencies.getMyRequests().call(
        clientId: userId,
      );
      if (!result.isSuccess) {
        throw StateError('Failed to load requests');
      }

      final requests = result.valueOrNull ?? <PhotoRequest>[];
      _draftRequests
        ..clear()
        ..addAll(requests.where((request) => request.status == 'draft'));
      _activeRequests
        ..clear()
        ..addAll(
          requests.where(
            (request) =>
                request.status != 'draft' &&
                request.status != 'closed' &&
                request.status != 'canceled' &&
                request.status != 'expired',
          ),
        );
      _closedRequests
        ..clear()
        ..addAll(
          requests.where(
            (request) =>
                request.status == 'closed' ||
                request.status == 'canceled' ||
                request.status == 'expired',
          ),
        );

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (_) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.myRequests),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => AppRouter.goToCreateRequest(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.drafts),
            Tab(text: localizations.active),
            Tab(text: localizations.closed),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError && _activeRequests.isEmpty && _closedRequests.isEmpty
          ? EmptyStates.error(onRetry: _loadRequests)
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestsList(_draftRequests, localizations),
                  _buildRequestsList(_activeRequests, localizations),
                  _buildRequestsList(_closedRequests, localizations),
                ],
              ),
            ),
    );
  }

  Widget _buildRequestsList(
    List<PhotoRequest> requests,
    AppLocalizations localizations,
  ) {
    if (requests.isEmpty) {
      return EmptyState(
        icon: Icons.photo_camera_outlined,
        title: localizations.noRequests,
        message: localizations.requestsEmptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => AppRouter.goToRequestDetails(context, request.id),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          request.type,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      _StatusChip(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_formatDate(request.date)} - ${request.time}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${request.offersCount} ${localizations.offers}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color _statusColor(ColorScheme scheme) {
    switch (status) {
      case 'draft':
        return scheme.primary;
      case 'awaiting_offers':
      case 'published':
        return scheme.secondary;
      case 'offer_selected':
        return scheme.tertiary;
      case 'closed':
        return scheme.primary;
      case 'canceled':
        return scheme.error;
      case 'expired':
        return scheme.secondary;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = _statusColor(scheme);
    final localizations = AppLocalizations.of(context);
    final label = switch (status) {
      'draft' => localizations.requestStatusDraft,
      'awaiting_offers' => localizations.requestStatusAwaitingOffers,
      'published' => localizations.requestStatusPublished,
      'offer_selected' => localizations.requestStatusOfferSelected,
      'closed' => localizations.requestStatusClosed,
      'canceled' => localizations.requestStatusCanceled,
      'expired' => localizations.requestStatusExpired,
      _ => status.replaceAll('_', ' ').toUpperCase(),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
