import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/router/app_router.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/core/widgets/loading_widgets.dart';
import 'package:luqta/features/auth/auth_dependencies.dart';
import 'package:luqta/features/profile/profile_dependencies.dart';
import 'package:luqta/features/requests/domain/entities/photo_request.dart';
import 'package:luqta/features/requests/requests_dependencies.dart';

class PhotographerRequestsScreen extends StatefulWidget {
  const PhotographerRequestsScreen({super.key});

  @override
  State<PhotographerRequestsScreen> createState() =>
      _PhotographerRequestsScreenState();
}

class _PhotographerRequestsScreenState
    extends State<PhotographerRequestsScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  final List<PhotoRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String? governorate;
      final userResult = await AuthDependencies.getCurrentUser().call();
      if (!mounted) return;
      final userId = userResult.valueOrNull?.id;
      if (userId != null && userId.isNotEmpty) {
        final profileResult = await ProfileDependencies.getUserProfile().call(
          userId: userId,
        );
        if (!mounted) return;
        governorate = profileResult.valueOrNull?.governorate;
      }

      final result = await RequestsDependencies.getOpenRequests().call(
        governorate: governorate,
      );
      if (!mounted) return;
      if (!result.isSuccess) {
        throw StateError('Failed to load requests');
      }

      _requests
        ..clear()
        ..addAll(result.valueOrNull ?? <PhotoRequest>[]);

      setState(() => _isLoading = false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to load open requests: $e');
      }
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.openRequests)),
      body: _isLoading
          ? const LoadingIndicator()
          : _hasError
          ? EmptyStates.error(onRetry: _loadRequests)
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: _requests.isEmpty
                  ? EmptyState(
                      icon: Icons.photo_camera_outlined,
                      title: localizations.noRequestsFound,
                      message: localizations.noRequestsFoundMessage,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final request = _requests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(request.type),
                            subtitle: Text(
                              '${request.date} - ${request.time}\n${request.governorate}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => AppRouter.goToRequestDetails(
                              context,
                              request.id,
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
