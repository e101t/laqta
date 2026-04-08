import 'package:flutter/material.dart';
import 'package:laqta/core/localization/app_localizations.dart';
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

  bool get _isArabic =>
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';

  String _tr({required String ar, required String en}) => _isArabic ? ar : en;

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
        _error = _tr(
          ar: '\u062a\u0639\u0630\u0631 \u062a\u062d\u0645\u064a\u0644 \u0627\u0644\u0625\u062d\u0635\u0627\u0626\u064a\u0627\u062a.',
          en: 'Failed to load analytics.',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(localizations.analyticsLabel)),
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
                  child: Text(localizations.retry),
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
        title: Text(localizations.analyticsLabel),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'today',
                child: Text(
                  _tr(ar: '\u0627\u0644\u064a\u0648\u0645', en: 'Today'),
                ),
              ),
              PopupMenuItem(
                value: 'week',
                child: Text(
                  _tr(
                    ar: '\u0647\u0630\u0627 \u0627\u0644\u0623\u0633\u0628\u0648\u0639',
                    en: 'This week',
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'month',
                child: Text(
                  _tr(
                    ar: '\u0647\u0630\u0627 \u0627\u0644\u0634\u0647\u0631',
                    en: 'This month',
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'year',
                child: Text(
                  _tr(
                    ar: '\u0647\u0630\u0627 \u0627\u0644\u0639\u0627\u0645',
                    en: 'This year',
                  ),
                ),
              ),
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
              child: Text(
                '${_tr(ar: '\u0627\u0644\u0641\u062a\u0631\u0629', en: 'Period')}: ${_periodLabel(_selectedPeriod)}',
              ),
            ),
            const SizedBox(height: 16),
            _MetricCard(
              title: _tr(
                ar: '\u0637\u0644\u0628\u0627\u062a \u0627\u0644\u062d\u062c\u0632',
                en: 'Booking requests',
              ),
              value: '${metrics.bookingRequests}',
              icon: Icons.inbox,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0627\u0644\u062d\u062c\u0648\u0632\u0627\u062a \u0627\u0644\u0645\u0643\u062a\u0645\u0644\u0629',
                en: 'Completed bookings',
              ),
              value: '${metrics.completedBookings}',
              icon: Icons.check_circle,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0627\u0644\u0625\u064a\u0631\u0627\u062f\u0627\u062a',
                en: 'Revenue',
              ),
              value: '${metrics.revenue.toStringAsFixed(0)} IQD',
              icon: Icons.payments,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0645\u062a\u0648\u0633\u0637 \u0627\u0644\u062a\u0642\u064a\u064a\u0645',
                en: 'Average rating',
              ),
              value: metrics.avgRating.toStringAsFixed(2),
              icon: Icons.star,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0625\u062c\u0645\u0627\u0644\u064a \u0627\u0644\u0645\u0634\u0627\u0647\u062f\u0627\u062a',
                en: 'Total views',
              ),
              value: '${metrics.totalViews}',
              icon: Icons.visibility,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0627\u0644\u062a\u0641\u0627\u0639\u0644 \u0645\u0639 \u0627\u0644\u0645\u0644\u0641',
                en: 'Profile engagement',
              ),
              value: '${metrics.profileClicks}',
              icon: Icons.touch_app,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0627\u0644\u0642\u0635\u0635 \u0627\u0644\u0645\u0646\u0634\u0648\u0631\u0629',
                en: 'Story items published',
              ),
              value: '${metrics.storyViews}',
              icon: Icons.auto_stories,
            ),
            _MetricCard(
              title: _tr(
                ar: '\u0645\u062a\u0627\u0628\u0639\u0648\u0646 \u062c\u062f\u062f',
                en: 'New followers',
              ),
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
      'today' => _tr(ar: '\u0627\u0644\u064a\u0648\u0645', en: 'Today'),
      'month' => _tr(
        ar: '\u0647\u0630\u0627 \u0627\u0644\u0634\u0647\u0631',
        en: 'This month',
      ),
      'year' => _tr(
        ar: '\u0647\u0630\u0627 \u0627\u0644\u0639\u0627\u0645',
        en: 'This year',
      ),
      _ => _tr(
        ar: '\u0647\u0630\u0627 \u0627\u0644\u0623\u0633\u0628\u0648\u0639',
        en: 'This week',
      ),
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
