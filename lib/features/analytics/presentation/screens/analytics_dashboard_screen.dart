import 'package:flutter/material.dart';
import 'package:laqta/features/analytics/analytics_dependencies.dart';
import 'package:laqta/features/analytics/domain/entities/analytics_metrics.dart';
import 'package:laqta/features/auth/auth_dependencies.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'week';
  bool _isLoading = true;
  String? _error;
  AnalyticsMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userResult = await AuthDependencies.getCurrentUser().call();
      final userId = userResult.valueOrNull?.id;
      if (userId == null || userId.isEmpty) {
        throw StateError('Missing user');
      }

      final result = await AnalyticsDependencies.getPhotographerAnalytics()
          .call(photographerId: userId, period: _selectedPeriod);

      if (!result.isSuccess || result.valueOrNull == null) {
        throw StateError('Failed to load analytics');
      }

      if (!mounted) return;
      setState(() {
        _metrics = result.valueOrNull;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load analytics.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analytics')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loadAnalytics,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final metrics =
        _metrics ??
        const AnalyticsMetrics(
          totalViews: 0,
          profileClicks: 0,
          bookingRequests: 0,
          completedBookings: 0,
          revenue: 0,
          newFollowers: 0,
          storyViews: 0,
          avgRating: 0,
        );

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'today', child: Text('Today')),
              PopupMenuItem(value: 'week', child: Text('This week')),
              PopupMenuItem(value: 'month', child: Text('This month')),
              PopupMenuItem(value: 'year', child: Text('This year')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('Period: ${_periodLabel(_selectedPeriod)}'),
            ),
            const SizedBox(height: 16),
            _MetricCard(
              title: 'Booking requests',
              value: '${metrics.bookingRequests}',
              icon: Icons.inbox,
            ),
            _MetricCard(
              title: 'Completed bookings',
              value: '${metrics.completedBookings}',
              icon: Icons.check_circle,
            ),
            _MetricCard(
              title: 'Revenue',
              value: '${metrics.revenue.toStringAsFixed(0)} IQD',
              icon: Icons.payments,
            ),
            _MetricCard(
              title: 'Average rating',
              value: metrics.avgRating.toStringAsFixed(2),
              icon: Icons.star,
            ),
            _MetricCard(
              title: 'Total views',
              value: '${metrics.totalViews}',
              icon: Icons.visibility,
            ),
            _MetricCard(
              title: 'Profile engagement',
              value: '${metrics.profileClicks}',
              icon: Icons.touch_app,
            ),
            _MetricCard(
              title: 'Story items published',
              value: '${metrics.storyViews}',
              icon: Icons.auto_stories,
            ),
            _MetricCard(
              title: 'New followers',
              value: '${metrics.newFollowers}',
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }

  String _periodLabel(String period) {
    return switch (period) {
      'today' => 'Today',
      'month' => 'This month',
      'year' => 'This year',
      _ => 'This week',
    };
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: textTheme.bodyMedium)),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
