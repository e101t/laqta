import 'package:flutter/material.dart';
import 'package:luqta/core/constants/app_theme.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  String _selectedPeriod = 'week';
  bool _isLoading = true;

  // Mock data
  final Map<String, dynamic> _analytics = {
    'totalViews': 1250,
    'profileClicks': 320,
    'bookingRequests': 45,
    'completedBookings': 38,
    'revenue': 5700000.0,
    'newFollowers': 28,
    'storyViews': 890,
    'avgRating': 4.8,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('الإحصائيات 📊'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_today),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'today', child: Text('اليوم')),
              const PopupMenuItem(value: 'week', child: Text('هذا الأسبوع')),
              const PopupMenuItem(value: 'month', child: Text('هذا الشهر')),
              const PopupMenuItem(value: 'year', child: Text('هذه السنة')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Period Selector
            _buildPeriodInfo(),
            const SizedBox(height: 20),

            // Key Metrics Grid
            _buildMetricsGrid(),
            const SizedBox(height: 24),

            // Revenue Chart
            _buildRevenueSection(),
            const SizedBox(height: 24),

            // Engagement Stats
            _buildEngagementSection(),
            const SizedBox(height: 24),

            // Top Performing
            _buildTopPerformingSection(),
            const SizedBox(height: 24),

            // Demographics
            _buildDemographicsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodInfo() {
    String period = '';
    switch (_selectedPeriod) {
      case 'today':
        period = 'اليوم';
        break;
      case 'week':
        period = 'آخر 7 أيام';
        break;
      case 'month':
        period = 'آخر 30 يوم';
        break;
      case 'year':
        period = 'آخر 12 شهر';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.cta.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'عرض الإحصائيات لـ $period',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          '👁️',
          'مشاهدات الملف',
          '${_analytics['totalViews']}',
          '+12%',
          isPositive: true,
        ),
        _buildMetricCard(
          '📅',
          'طلبات حجز',
          '${_analytics['bookingRequests']}',
          '+8%',
          isPositive: true,
        ),
        _buildMetricCard(
          '💰',
          'الإيرادات',
          '${(_analytics['revenue'] / 1000).toStringAsFixed(0)}K',
          '+15%',
          isPositive: true,
        ),
        _buildMetricCard(
          '⭐',
          'التقييم',
          '${_analytics['avgRating']}',
          '+0.2',
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String emoji,
    String label,
    String value,
    String change, {
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 11,
                        color: isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإيرادات 💰', style: AppTypography.h3),
              Text(
                '5,700,000 IQD',
                style: AppTypography.h4.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Simple bar chart visualization
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRevenueBar('السبت', 0.6),
              _buildRevenueBar('الأحد', 0.8),
              _buildRevenueBar('الإثنين', 0.5),
              _buildRevenueBar('الثلاثاء', 0.9),
              _buildRevenueBar('الأربعاء', 0.7),
              _buildRevenueBar('الخميس', 1.0),
              _buildRevenueBar('الجمعة', 0.4),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueBar(String day, double percentage) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 120 * percentage,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [AppColors.primary, AppColors.cta],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildEngagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('التفاعل 📈', style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildEngagementItem(
            'نقرات الملف',
            _analytics['profileClicks'],
            Icons.touch_app,
          ),
          _buildEngagementItem(
            'مشاهدات القصص',
            _analytics['storyViews'],
            Icons.remove_red_eye,
          ),
          _buildEngagementItem(
            'متابعين جدد',
            _analytics['newFollowers'],
            Icons.person_add,
          ),
          _buildEngagementItem(
            'حجوزات مكتملة',
            _analytics['completedBookings'],
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementItem(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.bodyMedium),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value / 1000,
                    minHeight: 6,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$value',
            style: AppTypography.h4.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الأفضل أداءً 🏆', style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildTopItem('1', 'تصوير زفاف', '15 حجز', AppColors.cta),
          _buildTopItem('2', 'تصوير شخصي', '12 حجز', AppColors.success),
          _buildTopItem('3', 'تصوير منتجات', '8 حجز', AppColors.info),
        ],
      ),
    );
  }

  Widget _buildTopItem(
    String rank,
    String title,
    String bookings,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: AppTypography.bodyLarge)),
          Text(
            bookings,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الجمهور 👥', style: AppTypography.h3),
          const SizedBox(height: 16),
          _buildDemographicItem('بغداد', 45, AppColors.primary),
          _buildDemographicItem('البصرة', 25, AppColors.cta),
          _buildDemographicItem('أربيل', 18, AppColors.success),
          _buildDemographicItem('محافظات أخرى', 12, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildDemographicItem(String city, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(city, style: AppTypography.bodyMedium),
              Text(
                '$percentage%',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}
