import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
import 'package:laqta/core/pagination/paginated_list_widget.dart';
import 'package:laqta/core/services/backend_api_client.dart';
import 'package:laqta/core/widgets/empty_states.dart';
import 'package:laqta/features/admin/presentation/screens/admin_dispute_details_screen.dart';
import 'package:laqta/features/disputes/data/dtos/dispute_dto.dart';
import 'package:laqta/features/disputes/data/mappers/dispute_mapper.dart';
import 'package:laqta/features/disputes/domain/entities/dispute.dart';

class AdminDisputesScreen extends StatefulWidget {
  const AdminDisputesScreen({super.key});

  @override
  State<AdminDisputesScreen> createState() => _AdminDisputesScreenState();
}

class _AdminDisputesScreenState extends State<AdminDisputesScreen> {
  final _apiClient = BackendApiClient();
  // 'open' | 'resolved' | 'all'
  String _selectedStatus = 'open';
  int _refreshKey = 0;

  Future<List<Dispute>> _fetchPage(int page, int pageSize) async {
    final statusParam =
        _selectedStatus == 'all' ? '' : '&status=$_selectedStatus';
    final response = await _apiClient.get(
      '/disputes?page=$page&limit=$pageSize$statusParam',
    );
    final raw = _readList(response, 'disputes');
    return raw
        .map((json) => DisputeMapper.toDomain(DisputeDto.fromJson(json)))
        .toList();
  }

  List<Map<String, dynamic>> _readList(dynamic response, String key) {
    if (response is Map<String, dynamic>) {
      final value = response[key];
      if (value is List) {
        return value
            .whereType<Map<Object?, Object?>>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }
    if (response is List) {
      return response
          .whereType<Map<Object?, Object?>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }
    return const [];
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    const statusOptions = [
      ('الكل', 'all'),
      ('مفتوح', 'open'),
      ('محلول', 'resolved'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminDisputes)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: statusOptions.map((entry) {
                  final (label, value) = entry;
                  final selected = _selectedStatus == value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: scheme.primaryContainer,
                      checkmarkColor: scheme.onPrimaryContainer,
                      onSelected: (_) {
                        if (!selected) {
                          setState(() {
                            _selectedStatus = value;
                            _refreshKey++;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: PaginatedListWidget<Dispute>(
              key: ValueKey('disputes-$_selectedStatus-$_refreshKey'),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              onLoadMore: _fetchPage,
              emptyWidget: EmptyState(
                icon: Icons.warning_amber_outlined,
                title: localizations.noDisputes,
                message: localizations.noDisputesMessage,
              ),
              errorWidget: EmptyStates.error(
                onRetry: () => setState(() => _refreshKey++),
              ),
              itemBuilder: (context, dispute, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.warning_amber),
                    title: Text(dispute.reason, style: textTheme.titleMedium),
                    subtitle: Text(
                      'Booking ${dispute.bookingId}\n'
                      'Opened ${_formatDate(dispute.createdAt)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final resolved = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminDisputeDetailsScreen(dispute: dispute),
                        ),
                      );
                      if (resolved == true && mounted) {
                        setState(() => _refreshKey++);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
