import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/widgets/empty_states.dart';
import 'package:luqta/features/admin/presentation/screens/admin_dispute_details_screen.dart';
import 'package:luqta/features/disputes/disputes_dependencies.dart';
import 'package:luqta/features/disputes/domain/entities/dispute.dart';

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  final List<Dispute> _disputes = [];

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await DisputesDependencies.getOpenDisputes().call();
      if (!result.isSuccess) {
        throw StateError('Failed to load disputes');
      }
      _disputes
        ..clear()
        ..addAll(result.valueOrNull ?? <Dispute>[]);
    } catch (_) {
      _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminDisputes)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? EmptyStates.error(onRetry: _loadDisputes)
          : RefreshIndicator(
              onRefresh: _loadDisputes,
              child: _disputes.isEmpty
                  ? EmptyState(
                      icon: Icons.warning_amber_outlined,
                      title: localizations.noDisputes,
                      message: localizations.noDisputesMessage,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _disputes.length,
                      itemBuilder: (context, index) {
                        final dispute = _disputes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber),
                            title: Text(
                              dispute.reason,
                              style: textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              'Booking ${dispute.bookingId}\n'
                              'Opened ${_formatDate(dispute.createdAt)}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () async {
                              final resolved =
                                  await Navigator.of(context).push<bool>(
                                MaterialPageRoute(
                                  builder: (_) => AdminDisputeDetailsScreen(
                                    dispute: dispute,
                                  ),
                                ),
                              );
                              if (resolved == true) {
                                _loadDisputes();
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
