import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:luqta/core/localization/app_localizations.dart';
import 'package:luqta/core/security/secure_firestore.dart';
import 'package:luqta/features/admin/presentation/screens/admin_disputes_screen.dart';
import 'package:luqta/features/admin/presentation/screens/admin_reports_screen.dart';
import 'package:luqta/features/admin/presentation/screens/admin_users_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  _AdminStats? _stats;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final SecureFirestore _secure = SecureFirestore(_firestore);

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final requestsSnapshot = await _secure.guard(
        () => _firestore
            .collection('requests')
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .get(),
      );
      final bookingsSnapshot = await _secure.guard(
        () => _firestore.collection('bookings').get(),
      );
      final cancellationsSnapshot = await _secure.guard(
        () => _firestore
            .collection('bookings')
            .where('status', isEqualTo: 'canceled')
            .get(),
      );
      final disputesSnapshot = await _secure.guard(
        () =>
            _firestore.collection('disputes').where('status', isEqualTo: 'open').get(),
      );

      _stats = _AdminStats(
        requestsToday: requestsSnapshot.docs.length,
        bookingsTotal: bookingsSnapshot.docs.length,
        cancellations: cancellationsSnapshot.docs.length,
        openDisputes: disputesSnapshot.docs.length,
      );
    } catch (_) {
      _hasError = true;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(localizations.adminDashboard)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
          ? Center(
              child: TextButton(
                onPressed: _loadStats,
                child: Text(localizations.retry),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _StatsGrid(stats: _stats!, localizations: localizations),
                  const SizedBox(height: 16),
                  _AdminActionCard(
                    title: localizations.adminDisputes,
                    subtitle: localizations.reviewDisputes,
                    icon: Icons.warning_amber,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminDisputesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    title: localizations.adminReports,
                    subtitle: localizations.reviewReports,
                    icon: Icons.flag_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminReportsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _AdminActionCard(
                    title: localizations.adminUsers,
                    subtitle: localizations.manageUsers,
                    icon: Icons.people_outline,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _AdminStats {
  final int requestsToday;
  final int bookingsTotal;
  final int cancellations;
  final int openDisputes;

  const _AdminStats({
    required this.requestsToday,
    required this.bookingsTotal,
    required this.cancellations,
    required this.openDisputes,
  });
}

class _StatsGrid extends StatelessWidget {
  final _AdminStats stats;
  final AppLocalizations localizations;

  const _StatsGrid({
    required this.stats,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(label: localizations.requestsToday, value: stats.requestsToday),
        _StatCard(label: localizations.totalBookings, value: stats.bookingsTotal),
        _StatCard(label: localizations.cancellations, value: stats.cancellations),
        _StatCard(label: localizations.openDisputesCount, value: stats.openDisputes),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelSmall),
          const Spacer(),
          Text(
            value.toString(),
            style: textTheme.headlineSmall?.copyWith(color: scheme.primary),
          ),
        ],
      ),
    );
  }
}

class _AdminActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: scheme.primary),
        title: Text(title, style: textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
